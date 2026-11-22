#include <jni.h>
#include <EGL/egl.h>
#include <GLES3/gl3.h>
#include <android/log.h>
#include <pthread.h>
#include <unistd.h>
#include <dlfcn.h>
#include <link.h>
#include <elf.h>
#include <sys/mman.h>
#include <cstdio>
#include <cstdlib>
#include <cstdarg>
#include <cstring>
#include <cstdint>
#include <ctime>
#include <cmath>
#include <cerrno>
#include <algorithm>

#include "imgui.h"
#include "imgui_impl_opengl3.h"
#include "offsets.h"

#define LOG_FILE   "/data/user/0/com.robtopx.geometryjump/files/gd_modern_log.txt"
#define CFG_FILE   "/data/user/0/com.robtopx.geometryjump/files/gd_modern_config.bin"
#define LOGI(...)  __android_log_print(ANDROID_LOG_INFO, "GD_MOD", __VA_ARGS__)

void FileLog(const char* fmt, ...) {
    char buf[1024];
    va_list ap;
    va_start(ap, fmt);
    vsnprintf(buf, sizeof(buf), fmt, ap);
    va_end(ap);
    LOGI("%s", buf);
    FILE* f = fopen(LOG_FILE, "a");
    if (f) {
        time_t now = time(NULL);
        struct tm* t = localtime(&now);
        fprintf(f, "[%02d:%02d:%02d] [LIBGDMENU] %s\n", t->tm_hour, t->tm_min, t->tm_sec, buf);
        fflush(f);
        fclose(f);
    }
}

static inline float Clamp01(float v) { return v < 0.0f ? 0.0f : (v > 1.0f ? 1.0f : v); }
static inline float Lerp(float a, float b, float t) { return a + (b - a) * Clamp01(t); }

// Быстрый PRNG без зависимостей от libstdc++
static uint32_t g_RngState = 0x1337C0DEu;
static inline uint32_t RandU32() {
    uint32_t x = g_RngState;
    x ^= x << 13;
    x ^= x >> 17;
    x ^= x << 5;
    g_RngState = x;
    return x;
}
static inline int RandRange(int lo, int hi) {
    if (hi <= lo) return lo;
    return lo + (int)(RandU32() % (uint32_t)(hi - lo + 1));
}

typedef EGLBoolean (*PFN_eglSwapBuffers)(EGLDisplay, EGLSurface);
typedef EGLBoolean (*PFN_eglQuerySurface)(EGLDisplay, EGLSurface, EGLint, EGLint*);
typedef void (*PFN_TouchesBegin)(JNIEnv*, jobject, jint, jfloat, jfloat);
typedef void (*PFN_TouchesEnd)(JNIEnv*, jobject, jint, jfloat, jfloat);
typedef void (*PFN_TouchesMove)(JNIEnv*, jobject, jintArray, jfloatArray, jfloatArray);
typedef void (*PFN_TouchesCancel)(JNIEnv*, jobject, jintArray, jfloatArray, jfloatArray);

typedef void (*PFN_DestroyPlayer)(void*, void*, void*);
typedef void (*PFN_ResetLevel)(void*);
typedef void (*PFN_OnQuit)(void*);
typedef void (*PFN_GameUpdate)(void*, float);
typedef void (*PFN_ToggleFlipped)(void*, bool, bool);
typedef void (*PFN_ShakeCamera)(void*, float, float, float);
typedef void (*PFN_DeathEffect)(void*);
typedef void (*PFN_ActivateStreak)(void*);
typedef void (*PFN_DeactStreak)(void*, bool);
typedef void (*PFN_SchedulerUpdate)(void*, float);
typedef void (*PFN_ParticleUpdate)(void*, float);

static PFN_eglSwapBuffers p_eglSwapBuffers = nullptr;
static PFN_eglQuerySurface p_eglQuerySurface = nullptr;
static PFN_TouchesBegin p_TouchesBegin = nullptr;
static PFN_TouchesEnd p_TouchesEnd = nullptr;
static PFN_TouchesMove p_TouchesMove = nullptr;
static PFN_TouchesCancel p_TouchesCancel = nullptr;

static PFN_DestroyPlayer p_DestroyPlayer = nullptr;
static PFN_ResetLevel p_ResetLevel = nullptr;
static PFN_OnQuit p_OnQuit = nullptr;
static PFN_GameUpdate p_GameUpdate = nullptr;
static PFN_ToggleFlipped p_ToggleFlipped = nullptr;
static PFN_ShakeCamera p_ShakeCamera = nullptr;
static PFN_DeathEffect p_DeathEffect = nullptr;
static PFN_ActivateStreak p_ActivateStreak = nullptr;
static PFN_DeactStreak p_DeactStreak = nullptr;
static PFN_SchedulerUpdate p_SchedulerUpdate = nullptr;
static PFN_ParticleUpdate p_ParticleUpdate = nullptr;

static uintptr_t g_CocosBase = 0;

// Активные указатели уровня (очищаются в onQuit)
static void* g_PlayLayer = nullptr;
static void* g_GameLayer = nullptr;

static bool g_Init = false;
static bool g_ShowMenu = false;
static int g_Tab = 0; // Gameplay, Visuals, Settings

static ImFont* g_FontMain = nullptr;
static ImFont* g_FontSmall = nullptr;
static ImFont* g_FontTitle = nullptr;

// === SETTINGS V4 / saved inside game's writable private directory ===
static bool g_Noclip = false, g_InstantRespawn = false;
static bool g_NoMirror = false, g_NoShake = true;
static bool g_NoDeathFX = false, g_NoParticles = false;
static bool g_AlwaysTrail = false, g_NoTrail = false;
static bool g_ShowFPS = true, g_ShowTimer = false, g_ShowDeaths = false;
static bool g_ReducedMotion = false;
static bool g_HudRight = false;
static float g_Speed = 1.0f, g_MenuOpacity = 0.97f;
static float g_CircleRadius = 31.0f, g_CircleX = 108.0f, g_CircleY = 175.0f;
static int g_Deaths = 0, g_RespawnDelayFrames = 0;
static float g_AttemptSeconds = 0.0f;
static bool g_LevelDead = false;

struct ModConfig {
    uint32_t magic, version;
    uint8_t noclip, respawn, no_mirror, no_shake, no_death, no_particles;
    uint8_t always_trail, no_trail, fps, timer, deaths, reduced_motion, hud_right;
    uint8_t reserved[2];
    float speed, opacity, circle_radius, circle_x, circle_y;
};

void SaveConfig() {
    ModConfig c{};
    c.magic = 0x56414E54u; c.version = 5;
    c.noclip=g_Noclip; c.respawn=g_InstantRespawn; c.no_mirror=g_NoMirror; c.no_shake=g_NoShake;
    c.no_death=g_NoDeathFX; c.no_particles=g_NoParticles; c.always_trail=g_AlwaysTrail;
    c.no_trail=g_NoTrail; c.fps=g_ShowFPS; c.timer=g_ShowTimer; c.deaths=g_ShowDeaths;
    c.reduced_motion=g_ReducedMotion; c.hud_right=g_HudRight;
    c.speed=g_Speed; c.opacity=g_MenuOpacity; c.circle_radius=g_CircleRadius;
    c.circle_x=g_CircleX; c.circle_y=g_CircleY;
    FILE* f=fopen(CFG_FILE,"wb");
    if (f) { fwrite(&c,sizeof(c),1,f); fclose(f); }
}
void LoadConfig() {
    FILE* f=fopen(CFG_FILE,"rb"); if(!f) return;
    ModConfig c{}; bool valid=fread(&c,sizeof(c),1,f)==1 && c.magic==0x56414E54u && c.version==5;
    fclose(f); if(!valid) return;
    g_Noclip=c.noclip; g_InstantRespawn=c.respawn; g_NoMirror=c.no_mirror; g_NoShake=c.no_shake;
    g_NoDeathFX=c.no_death; g_NoParticles=c.no_particles; g_AlwaysTrail=c.always_trail;
    g_NoTrail=c.no_trail; if(g_NoTrail) g_AlwaysTrail=false;
    g_ShowFPS=c.fps; g_ShowTimer=c.timer; g_ShowDeaths=c.deaths;
    g_ReducedMotion=c.reduced_motion; g_HudRight=c.hud_right;
    g_Speed=std::max(0.25f,std::min(3.0f,c.speed));
    g_MenuOpacity=std::max(0.65f,std::min(1.0f,c.opacity));
    g_CircleRadius=std::max(24.0f,std::min(48.0f,c.circle_radius));
    if(c.circle_x>0 && c.circle_y>0) { g_CircleX=c.circle_x; g_CircleY=c.circle_y; }
}
void RestoreDefaults() {
    g_Noclip=false; g_InstantRespawn=false; g_NoMirror=false; g_NoShake=true;
    g_NoDeathFX=false; g_NoParticles=false; g_AlwaysTrail=false; g_NoTrail=false;
    g_ShowFPS=true; g_ShowTimer=false; g_ShowDeaths=false;
    g_ReducedMotion=false; g_HudRight=false; g_Speed=1.0f; g_MenuOpacity=0.97f;
    g_CircleRadius=31.0f; g_CircleX=108.0f; g_CircleY=175.0f; SaveConfig();
}
void ApplyPreset(int preset) {
    g_Speed=1.0f; g_Noclip=false; g_InstantRespawn=false;
    g_NoMirror=preset!=0; g_NoShake=preset!=0;
    g_NoDeathFX=preset==2; g_NoParticles=preset==2;
    g_NoTrail=preset==2; g_AlwaysTrail=false;
    g_ShowFPS=true; SaveConfig();
}

// === Animation state ===
static double g_LastTime = 0.0;
static float g_MenuAnim = 0.0f, g_CircleScale=1.0f;
static float g_FpsSmooth=60.0f, g_FrameTime=16.6f;
static float g_ToggleAnim[32]={}, g_HoverAnim[32]={}, g_NavAnim[3]={};
static float g_TabBlend=1.0f, g_MenuDrift=0.0f, g_HudFade=1.0f;
static int g_PreviousTab=0;
static bool g_CircleGrabbed=false, g_CircleMoved=false;
static float g_GrabStartX=0, g_GrabStartY=0;
static float g_GrabOffsetX=0, g_GrabOffsetY=0;
static float g_ScreenW=2376, g_ScreenH=1080;
static ImVec2 g_MenuPos(240,85),g_MenuSize(760,525);
static bool g_TouchCaptured=false;
static inline float Smooth(float x) { x=Clamp01(x); return x*x*(3.0f-2.0f*x); }
static inline float Approach(float val, float target, float dt, float rate) {
    return Lerp(val,target,g_ReducedMotion?1.0f:1.0f-expf(-rate*std::min(dt,0.10f)));
}
double GetNowSeconds() {
    struct timespec ts; clock_gettime(CLOCK_MONOTONIC,&ts);
    return (double)ts.tv_sec+(double)ts.tv_nsec*1e-9;
}

struct InlineHook {
    void* target = nullptr;
    uint8_t orig_bytes[16];
    uint8_t tramp_bytes[16];
    bool active = false;

    void install(void* target_func, void* hook_func) {
        if (!target_func || active) return;
        target = target_func;
        // Android devices can use either 4 KB or 16 KB memory pages.
        const long ps = sysconf(_SC_PAGESIZE);
        if (ps <= 0) { FileLog("Hook: cannot determine page size"); return; }
        const uintptr_t page_size = (uintptr_t)ps;
        const uintptr_t begin = (uintptr_t)target;
        const uintptr_t page = begin - (begin % page_size);
        const uintptr_t end = begin + 16;
        const size_t span = (size_t)((((end - page) + page_size - 1) / page_size) * page_size);
        if (mprotect((void*)page, span, PROT_READ | PROT_WRITE | PROT_EXEC) != 0) {
            FileLog("Hook: mprotect failed, errno=%d", errno);
            return;
        }
        memcpy(orig_bytes, target, 16);

        uint32_t code[2] = { 0x58000050, 0xD61F0200 };
        memcpy(tramp_bytes, code, 8);
        memcpy(tramp_bytes + 8, &hook_func, 8);

        memcpy(target, tramp_bytes, 16);
        __builtin___clear_cache((char*)target, (char*)target + 16);
        active = true;
    }
    void restore() {
        if (active) {
            memcpy(target, orig_bytes, 16);
            __builtin___clear_cache((char*)target, (char*)target + 16);
        }
    }
    void reenable() {
        if (active) {
            memcpy(target, tramp_bytes, 16);
            __builtin___clear_cache((char*)target, (char*)target + 16);
        }
    }
};

static InlineHook hk_eglSwapBuffers;
static InlineHook hk_TouchesBegin, hk_TouchesEnd, hk_TouchesMove, hk_TouchesCancel;
static InlineHook hk_DestroyPlayer, hk_ResetLevel, hk_OnQuit, hk_GameUpdate;
static InlineHook hk_ToggleFlipped, hk_ShakeCamera, hk_DeathEffect;
static InlineHook hk_ActivateStreak, hk_DeactStreak, hk_SchedulerUpdate, hk_ParticleUpdate;

// === Game callbacks ===
void hook_ResetLevel(void* self) {
    g_PlayLayer=self; g_GameLayer=self; g_RespawnDelayFrames=0;
    g_AttemptSeconds=0; g_LevelDead=false;
    hk_ResetLevel.restore(); p_ResetLevel(self); hk_ResetLevel.reenable();
}
void hook_OnQuit(void* self) {
    g_PlayLayer=nullptr; g_GameLayer=nullptr; g_RespawnDelayFrames=0;
    g_AttemptSeconds=0; g_LevelDead=false;
    hk_OnQuit.restore(); p_OnQuit(self); hk_OnQuit.reenable();
}
void hook_DestroyPlayer(void* self,void* player,void* object) {
    // PlayLayer may not yet be captured on the very first attempt.
    g_PlayLayer=self;
    g_GameLayer=self;
    if (g_Noclip) return;
    if (!g_LevelDead) { ++g_Deaths; g_LevelDead=true; }
    hk_DestroyPlayer.restore(); p_DestroyPlayer(self,player,object); hk_DestroyPlayer.reenable();
    if (g_InstantRespawn && p_ResetLevel && g_PlayLayer) g_RespawnDelayFrames=5;
}
void hook_GameUpdate(void* self,float dt) {
    if (g_PlayLayer && !g_LevelDead) g_AttemptSeconds+=std::max(0.0f,dt);
    hk_GameUpdate.restore(); p_GameUpdate(self,dt); hk_GameUpdate.reenable();
}
void hook_ToggleFlipped(void* s,bool f,bool i) {
    if(g_NoMirror) return;
    hk_ToggleFlipped.restore(); p_ToggleFlipped(s,f,i); hk_ToggleFlipped.reenable();
}
void hook_ShakeCamera(void* s,float d,float st,float iv) {
    if(g_NoShake) return;
    hk_ShakeCamera.restore(); p_ShakeCamera(s,d,st,iv); hk_ShakeCamera.reenable();
}
void hook_DeathEffect(void* s) {
    if(g_NoDeathFX) return;
    hk_DeathEffect.restore(); p_DeathEffect(s); hk_DeathEffect.reenable();
}
void hook_ActivateStreak(void* s) {
    if(g_NoTrail) return;
    hk_ActivateStreak.restore(); p_ActivateStreak(s); hk_ActivateStreak.reenable();
}
void hook_DeactStreak(void* s,bool st) {
    if(g_AlwaysTrail && !g_NoTrail) return;
    hk_DeactStreak.restore(); p_DeactStreak(s,st); hk_DeactStreak.reenable();
}
void hook_ParticleUpdate(void* s,float dt) {
    if(g_NoParticles) return;
    hk_ParticleUpdate.restore(); p_ParticleUpdate(s,dt); hk_ParticleUpdate.reenable();
}
void hook_SchedulerUpdate(void* s,float dt) {
    if (g_RespawnDelayFrames>0 && --g_RespawnDelayFrames==0 && g_PlayLayer && p_ResetLevel) {
        hook_ResetLevel(g_PlayLayer);
    }
    hk_SchedulerUpdate.restore(); p_SchedulerUpdate(s,dt*g_Speed); hk_SchedulerUpdate.reenable();
}
// === СКАНЕР СИМВОЛОВ ELF ===
static int ScanPhdrCallback(struct dl_phdr_info* info, size_t, void*) {
    if (!info->dlpi_name || !info->dlpi_name[0]) return 0;
    if (strstr(info->dlpi_name, "/system/") || strstr(info->dlpi_name, "/apex/") ||
        strstr(info->dlpi_name, "/vendor/") || strstr(info->dlpi_name, "libgdmenu.so")) return 0;

    uintptr_t bias = (uintptr_t)info->dlpi_addr;
    if (strstr(info->dlpi_name, "libcocos2dcpp.so")) g_CocosBase = bias;

    Elf64_Dyn* dyn = nullptr;
    for (int i = 0; i < info->dlpi_phnum; i++) {
        if (info->dlpi_phdr[i].p_type == PT_DYNAMIC) {
            dyn = (Elf64_Dyn*)(bias + info->dlpi_phdr[i].p_vaddr);
            break;
        }
    }
    if (!dyn) return 0;
    auto fix_ptr = [&](uintptr_t p) -> uintptr_t { return (p < bias) ? (bias + p) : p; };

    Elf64_Sym* symtab = nullptr;
    const char* strtab = nullptr;
    uint32_t *sysv_hash = nullptr, *gnu_hash = nullptr;
    for (Elf64_Dyn* d = dyn; d->d_tag != DT_NULL; d++) {
        if (d->d_tag == DT_SYMTAB) symtab = (Elf64_Sym*)fix_ptr(d->d_un.d_ptr);
        else if (d->d_tag == DT_STRTAB) strtab = (const char*)fix_ptr(d->d_un.d_ptr);
        else if (d->d_tag == DT_HASH) sysv_hash = (uint32_t*)fix_ptr(d->d_un.d_ptr);
        else if (d->d_tag == DT_GNU_HASH) gnu_hash = (uint32_t*)fix_ptr(d->d_un.d_ptr);
    }
    if (!symtab || !strtab) return 0;

    size_t num_syms = 0;
    if (sysv_hash) num_syms = sysv_hash[1];
    else if (gnu_hash) {
        uint32_t nb = gnu_hash[0], so = gnu_hash[1], bs = gnu_hash[2];
        const uint32_t* buckets = (const uint32_t*)((const uint64_t*)(gnu_hash + 4) + bs);
        const uint32_t* chains = buckets + nb;
        uint32_t mx = 0;
        for (uint32_t i = 0; i < nb; i++) if (buckets[i] > mx) mx = buckets[i];
        num_syms = so;
        if (mx >= so) { uint32_t idx = mx; while ((chains[idx - so] & 1) == 0) idx++; num_syms = idx + 1; }
    }

    for (size_t i = 0; i < num_syms; i++) {
        if (symtab[i].st_value == 0) continue;
        const char* name = strtab + symtab[i].st_name;
        void* addr = (void*)(bias + symtab[i].st_value);
        if (!p_TouchesBegin && strstr(name, "nativeTouchesBegin")) p_TouchesBegin = (PFN_TouchesBegin)addr;
        else if (!p_TouchesMove && strstr(name, "nativeTouchesMove")) p_TouchesMove = (PFN_TouchesMove)addr;
        else if (!p_TouchesEnd && strstr(name, "nativeTouchesEnd")) p_TouchesEnd = (PFN_TouchesEnd)addr;
        else if (!p_TouchesCancel && strstr(name, "nativeTouchesCancel")) p_TouchesCancel = (PFN_TouchesCancel)addr;
        else if (!p_DestroyPlayer && strstr(name, "9PlayLayer13destroyPlayer")) p_DestroyPlayer = (PFN_DestroyPlayer)addr;
        else if (!p_ResetLevel && strstr(name, "9PlayLayer10resetLevel")) p_ResetLevel = (PFN_ResetLevel)addr;
        else if (!p_OnQuit && strstr(name, "9PlayLayer6onQuit")) p_OnQuit = (PFN_OnQuit)addr;
        else if (!p_GameUpdate && strstr(name, "15GJBaseGameLayer6updateEf")) p_GameUpdate = (PFN_GameUpdate)addr;
        else if (!p_ToggleFlipped && strstr(name, "15GJBaseGameLayer13toggleFlipped")) p_ToggleFlipped = (PFN_ToggleFlipped)addr;
        else if (!p_ShakeCamera && strstr(name, "15GJBaseGameLayer11shakeCamera")) p_ShakeCamera = (PFN_ShakeCamera)addr;
        else if (!p_DeathEffect && strstr(name, "12PlayerObject15playDeathEffect")) p_DeathEffect = (PFN_DeathEffect)addr;
        else if (!p_ActivateStreak && strstr(name, "12PlayerObject14activateStreak")) p_ActivateStreak = (PFN_ActivateStreak)addr;
        else if (!p_DeactStreak && strstr(name, "12PlayerObject16deactivateStreak")) p_DeactStreak = (PFN_DeactStreak)addr;
        else if (!p_SchedulerUpdate && strstr(name, "11CCScheduler6updateEf")) p_SchedulerUpdate = (PFN_SchedulerUpdate)addr;
        else if (!p_ParticleUpdate && strstr(name, "16CCParticleSystem6updateEf")) p_ParticleUpdate = (PFN_ParticleUpdate)addr;
    }
    return 0;
}

bool IsPointInMenu(float x, float y) {
    return g_MenuAnim > 0.08f &&
           x >= g_MenuPos.x && x <= (g_MenuPos.x + g_MenuSize.x) &&
           y >= g_MenuPos.y && y <= (g_MenuPos.y + g_MenuSize.y);
}

void hook_TouchesBegin(JNIEnv* env, jobject thiz, jint id, jfloat x, jfloat y) {
    bool block = false;
    if (g_Init) {
        ImGuiIO& io = ImGui::GetIO();
        io.AddMousePosEvent(x, y);
        io.AddMouseButtonEvent(0, true);
        float dx = x - g_CircleX, dy = y - g_CircleY;
        if (dx * dx + dy * dy <= (g_CircleRadius + 24.0f) * (g_CircleRadius + 24.0f)) {
            g_CircleGrabbed = true; g_CircleMoved = false;
            g_GrabStartX = x; g_GrabStartY = y;
            g_GrabOffsetX = x - g_CircleX; g_GrabOffsetY = y - g_CircleY;
            block = true;
        } else if (IsPointInMenu(x, y)) block = true;
    }
    if (!block) { hk_TouchesBegin.restore(); p_TouchesBegin(env, thiz, id, x, y); hk_TouchesBegin.reenable(); }
}

void hook_TouchesMove(JNIEnv* env, jobject thiz, jintArray ids, jfloatArray xs, jfloatArray ys) {
    bool block = false;
    if (g_Init && xs && ys && env->GetArrayLength(xs) > 0) {
        jfloat x = 0, y = 0;
        env->GetFloatArrayRegion(xs, 0, 1, &x);
        env->GetFloatArrayRegion(ys, 0, 1, &y);
        ImGuiIO& io = ImGui::GetIO();
        io.AddMousePosEvent(x, y);
        if (g_CircleGrabbed) {
            if (std::hypot(x - g_GrabStartX, y - g_GrabStartY) > 10.0f) g_CircleMoved = true;
            if (g_CircleMoved) {
                g_CircleX = std::max(g_CircleRadius + 10.0f, std::min(x - g_GrabOffsetX, g_ScreenW - g_CircleRadius - 10.0f));
                g_CircleY = std::max(g_CircleRadius + 10.0f, std::min(y - g_GrabOffsetY, g_ScreenH - g_CircleRadius - 10.0f));
            }
            block = true;
        } else if (IsPointInMenu(x, y) || io.WantCaptureMouse) block = true;
    }
    if (!block) { hk_TouchesMove.restore(); p_TouchesMove(env, thiz, ids, xs, ys); hk_TouchesMove.reenable(); }
}

void hook_TouchesEnd(JNIEnv* env, jobject thiz, jint id, jfloat x, jfloat y) {
    bool block = false;
    if (g_Init) {
        ImGuiIO& io = ImGui::GetIO();
        io.AddMousePosEvent(x, y);
        io.AddMouseButtonEvent(0, false);
        if (g_CircleGrabbed) {
            if (!g_CircleMoved) g_ShowMenu = !g_ShowMenu;
            else SaveConfig();
            g_CircleGrabbed = false; g_CircleMoved = false;
            block = true;
        } else if (IsPointInMenu(x, y) || io.WantCaptureMouse) block = true;
    }
    if (!block) { hk_TouchesEnd.restore(); p_TouchesEnd(env, thiz, id, x, y); hk_TouchesEnd.reenable(); }
}

void hook_TouchesCancel(JNIEnv* env, jobject thiz, jintArray ids, jfloatArray xs, jfloatArray ys) {
    if (g_Init) { ImGui::GetIO().AddMouseButtonEvent(0, false); g_CircleGrabbed = false; g_CircleMoved = false; }
    hk_TouchesCancel.restore(); p_TouchesCancel(env, thiz, ids, xs, ys); hk_TouchesCancel.reenable();
}

// === VANTA: matte graphite, editorial typography, no neon/no gradients ===
static ImVec4 VAccent() { return ImVec4(.86f,.75f,.62f,1.0f); }
void ApplyObsidianStyle() {
    ImGuiStyle& s=ImGui::GetStyle();
    s.WindowRounding=19; s.ChildRounding=14; s.FrameRounding=10;
    s.GrabRounding=10; s.ScrollbarRounding=10; s.PopupRounding=12;
    s.WindowBorderSize=1; s.ChildBorderSize=1; s.FrameBorderSize=0;
    s.WindowPadding=ImVec2(18,16); s.FramePadding=ImVec2(12,10);
    s.ItemSpacing=ImVec2(9,10); s.ScrollbarSize=6; s.GrabMinSize=18;
    ImVec4* c=s.Colors;
    c[ImGuiCol_Text]=ImVec4(.93f,.93f,.92f,1);
    c[ImGuiCol_TextDisabled]=ImVec4(.48f,.49f,.51f,1);
    c[ImGuiCol_WindowBg]=ImVec4(.070f,.073f,.079f,1);
    c[ImGuiCol_ChildBg]=ImVec4(.088f,.092f,.099f,1);
    c[ImGuiCol_Border]=ImVec4(.22f,.23f,.25f,.75f);
    c[ImGuiCol_FrameBg]=ImVec4(.14f,.15f,.16f,1);
    c[ImGuiCol_FrameBgHovered]=ImVec4(.18f,.19f,.20f,1);
    c[ImGuiCol_FrameBgActive]=ImVec4(.21f,.22f,.23f,1);
    c[ImGuiCol_SliderGrab]=VAccent(); c[ImGuiCol_SliderGrabActive]=ImVec4(.98f,.87f,.71f,1);
    c[ImGuiCol_CheckMark]=VAccent();
    c[ImGuiCol_Button]=ImVec4(.155f,.164f,.177f,1);
    c[ImGuiCol_ButtonHovered]=ImVec4(.22f,.23f,.24f,1);
    c[ImGuiCol_ButtonActive]=ImVec4(.27f,.28f,.29f,1);
    c[ImGuiCol_Separator]=ImVec4(.24f,.25f,.27f,.63f);
    c[ImGuiCol_ScrollbarBg]=ImVec4(0,0,0,0);
    c[ImGuiCol_ScrollbarGrab]=ImVec4(.4f,.4f,.42f,.38f);
    c[ImGuiCol_Header]=ImVec4(.18f,.19f,.20f,1);
}
void LoadCrispFonts() {
    ImGuiIO& io=ImGui::GetIO();
    const char* candidates[]={"/system/fonts/Roboto-Regular.ttf","/system/fonts/RobotoStatic-Regular.ttf","/system/fonts/NotoSans-Regular.ttf","/system/fonts/DroidSans.ttf"};
    const char* path=nullptr;
    for(const char* p:candidates) if(access(p,R_OK)==0) {path=p;break;}
    if(path) {
        ImFontConfig c; c.OversampleH=2; c.OversampleV=2;
        g_FontMain=io.Fonts->AddFontFromFileTTF(path,23.0f,&c,io.Fonts->GetGlyphRangesCyrillic());
        g_FontSmall=io.Fonts->AddFontFromFileTTF(path,18.0f,&c,io.Fonts->GetGlyphRangesCyrillic());
        g_FontTitle=io.Fonts->AddFontFromFileTTF(path,31.0f,&c,io.Fonts->GetGlyphRangesCyrillic());
    } else { io.FontGlobalScale=1.6f; }
}
static void LightLabel(const char* text) {
    if(g_FontSmall) ImGui::PushFont(g_FontSmall);
    ImGui::TextColored(ImVec4(.59f,.60f,.62f,1),"%s",text);
    if(g_FontSmall) ImGui::PopFont();
}
static bool PrettySwitch(const char* id,const char* title,const char* note,bool* value,int index,float dt,bool available=true) {
    float w=ImGui::GetContentRegionAvail().x, h=68.0f;
    ImVec2 p=ImGui::GetCursorScreenPos();
    ImGui::InvisibleButton(id,ImVec2(w,h));
    bool hovered=available&&ImGui::IsItemHovered();
    bool clicked=available&&ImGui::IsItemClicked();
    if(clicked) { *value=!*value; SaveConfig(); }
    g_ToggleAnim[index]=Approach(g_ToggleAnim[index],*value?1.0f:0.0f,dt,15);
    g_HoverAnim[index]=Approach(g_HoverAnim[index],hovered?1.0f:0.0f,dt,12);
    float t=Smooth(g_ToggleAnim[index]), v=g_HoverAnim[index];
    ImDrawList* d=ImGui::GetWindowDrawList();
    int bg=(int)Lerp(28,36,v);
    // Rounded border constructed from two filled rects: compatible with old/new ImGui.
    // Some ImGui versions provide two ambiguous AddRect() overloads.
    d->AddRectFilled(p, ImVec2(p.x+w,p.y+h),
                     IM_COL32(80,83,88,(int)Lerp(35.0f,90.0f,v)), 12.0f);
    d->AddRectFilled(ImVec2(p.x+1.0f,p.y+1.0f),
                     ImVec2(p.x+w-1.0f,p.y+h-1.0f),
                     IM_COL32(bg,bg+2,bg+4,255), 11.0f);
    ImU32 fg=available?IM_COL32(235,235,233,255):IM_COL32(115,118,120,255);
    ImU32 sub=available?IM_COL32(142,146,151,255):IM_COL32(89,91,95,255);
    if(g_FontMain) ImGui::PushFont(g_FontMain);
    d->AddText(ImVec2(p.x+17,p.y+9),fg,title);
    if(g_FontMain) ImGui::PopFont();
    if(g_FontSmall) ImGui::PushFont(g_FontSmall);
    d->AddText(ImVec2(p.x+17,p.y+40),sub,note);
    if(g_FontSmall) ImGui::PopFont();
    const float sw=57,sh=32,sx=p.x+w-sw-16,sy=p.y+18;
    ImVec4 off(.30f,.31f,.33f,1),on=VAccent();
    ImVec4 mix(Lerp(off.x,on.x,t),Lerp(off.y,on.y,t),Lerp(off.z,on.z,t),1);
    d->AddRectFilled(ImVec2(sx,sy),ImVec2(sx+sw,sy+sh),ImGui::GetColorU32(mix),16);
    float knob=sx+16+(sw-32)*t;
    d->AddCircleFilled(ImVec2(knob,sy+sh*.5f),11.5f,IM_COL32(27,29,32,255),28);
    return clicked;
}
static bool NavItem(const char* id,const char* text,int idx,float dt) {
    bool active=g_Tab==idx;
    float w=ImGui::GetContentRegionAvail().x;
    ImVec2 p=ImGui::GetCursorScreenPos();
    ImGui::InvisibleButton(id,ImVec2(w,47));
    bool hovered=ImGui::IsItemHovered(); bool pressed=ImGui::IsItemClicked();
    if(pressed && !active) { g_PreviousTab=g_Tab; g_Tab=idx; g_TabBlend=0; }
    g_NavAnim[idx]=Approach(g_NavAnim[idx],active?1:(hovered?.42f:0),dt,13);
    float a=Smooth(g_NavAnim[idx]);
    ImDrawList* d=ImGui::GetWindowDrawList();
    d->AddRectFilled(p,ImVec2(p.x+w,p.y+47),IM_COL32(53,54,57,(int)(a*190)),11);
    d->AddRectFilled(ImVec2(p.x+1,p.y+10),ImVec2(p.x+3,p.y+37),IM_COL32(220,192,159,(int)(a*255)),2);
    if(g_FontMain) ImGui::PushFont(g_FontMain);
    d->AddText(ImVec2(p.x+18,p.y+11),active?IM_COL32(237,236,234,255):IM_COL32(158,161,166,255),text);
    if(g_FontMain) ImGui::PopFont();
    return pressed;
}
static void SectionTitle(const char* heading,const char* sub) {
    if(g_FontTitle) ImGui::PushFont(g_FontTitle); ImGui::TextUnformatted(heading);
    if(g_FontTitle) ImGui::PopFont();
    if(sub&&*sub) LightLabel(sub);
    ImGui::Spacing();
}
static void RowButton(const char* title,void(*action)()) {
    if (ImGui::Button(title,ImVec2(ImGui::GetContentRegionAvail().x,43))) action();
}
static void SpeedPreset(const char* name,float value,float w) {
    bool selected=fabsf(g_Speed-value)<.02f;
    if(selected) {ImGui::PushStyleColor(ImGuiCol_Button,VAccent());ImGui::PushStyleColor(ImGuiCol_Text,ImVec4(.11f,.11f,.12f,1));}
    if(ImGui::Button(name,ImVec2(w,41))) {g_Speed=value;SaveConfig();}
    if(selected) ImGui::PopStyleColor(2);
}
static void DrawHud(float dt) {
    if(!(g_ShowFPS||g_ShowTimer||g_ShowDeaths)) return;
    g_HudFade=Approach(g_HudFade,g_ShowMenu?.43f:1.0f,dt,7);
    ImDrawList* d=ImGui::GetForegroundDrawList();
    char str[120]="";
    if(g_ShowFPS) snprintf(str+strlen(str),sizeof(str)-strlen(str),"%.0f FPS / %.1f ms",g_FpsSmooth,g_FrameTime);
    if(g_ShowTimer && g_PlayLayer) snprintf(str+strlen(str),sizeof(str)-strlen(str),"  /  %.1fs",g_AttemptSeconds);
    if(g_ShowDeaths) snprintf(str+strlen(str),sizeof(str)-strlen(str),"  /  %d deaths",g_Deaths);
    if(!*str) return;
    if(g_FontSmall) ImGui::PushFont(g_FontSmall);
    ImVec2 sz=ImGui::CalcTextSize(str);
    float x=g_HudRight?g_ScreenW-sz.x-48:22.0f;
    float y=18.0f;
    d->AddRectFilled(ImVec2(x,y),ImVec2(x+sz.x+26,y+sz.y+17),IM_COL32(18,19,22,(int)(217*g_HudFade)),11);
    d->AddText(ImVec2(x+13,y+8),IM_COL32(228,227,225,(int)(255*g_HudFade)),str);
    if(g_FontSmall) ImGui::PopFont();
}
void DrawMenu(float dt) {
    g_FpsSmooth=Approach(g_FpsSmooth,1.0f/std::max(dt,.001f),dt,7);
    g_FrameTime=Approach(g_FrameTime,dt*1000.0f,dt,8);
    g_MenuAnim=Approach(g_MenuAnim,g_ShowMenu?1.0f:0.0f,dt,14);
    if(g_MenuAnim<.003f) g_MenuAnim=0;
    g_CircleScale=Approach(g_CircleScale,g_CircleGrabbed?.88f:(g_ShowMenu?1.08f:1),dt,15);
    g_TabBlend=Approach(g_TabBlend,1,dt,10);
    g_MenuDrift+=std::min(dt,.05f);
    ImGui_ImplOpenGL3_NewFrame(); ImGui::NewFrame();
    DrawHud(dt);
    // Quiet utility bubble with responsive outline and subtle breathing.
    ImDrawList* dl=ImGui::GetForegroundDrawList();
    ImVec2 b(g_CircleX,g_CircleY);
    float r=g_CircleRadius*g_CircleScale;
    dl->AddCircleFilled(ImVec2(b.x,b.y+4),r+2,IM_COL32(0,0,0,65),48);
    dl->AddCircleFilled(b,r,IM_COL32(26,28,31,248),48);
    float stroke=g_ShowMenu?1.0f:.5f+.5f*sinf(g_MenuDrift*2.2f);
    dl->AddCircle(b,r,IM_COL32(225,195,157,(int)(80+130*stroke)),48,1.8f);
    // Two simple horizontal bars, not an AI icon.
    dl->AddLine(ImVec2(b.x-10,b.y-4),ImVec2(b.x+10,b.y-4),IM_COL32(236,234,230,255),2.3f);
    dl->AddLine(ImVec2(b.x-10,b.y+5),ImVec2(b.x+5,b.y+5),IM_COL32(236,234,230,255),2.3f);
    if(g_MenuAnim>.012f) {
        const float ww=std::min(810.0f,std::max(360.0f,g_ScreenW-36.0f));
        const float hh=std::min(545.0f,std::max(330.0f,g_ScreenH-40.0f));
        ImVec2 center((g_ScreenW-ww)*.5f,(g_ScreenH-hh)*.5f);
        center.y+= (1.0f-Smooth(g_MenuAnim))*20.0f;
        ImGui::SetNextWindowPos(center,ImGuiCond_Always);
        ImGui::SetNextWindowSize(ImVec2(ww,hh),ImGuiCond_Always);
        ImGui::PushStyleVar(ImGuiStyleVar_Alpha,Smooth(g_MenuAnim));
        ImGui::PushStyleColor(ImGuiCol_WindowBg,ImVec4(.070f,.073f,.079f,g_MenuOpacity));
        ImGuiWindowFlags f=ImGuiWindowFlags_NoTitleBar|ImGuiWindowFlags_NoResize|ImGuiWindowFlags_NoCollapse|ImGuiWindowFlags_NoSavedSettings|ImGuiWindowFlags_NoMove;
        if(ImGui::Begin("##VantaMenu",nullptr,f)) {
            g_MenuPos=ImGui::GetWindowPos(); g_MenuSize=ImGui::GetWindowSize();
            ImVec2 cursor=ImGui::GetCursorScreenPos();
            ImDrawList* d=ImGui::GetWindowDrawList();
            d->AddCircleFilled(ImVec2(cursor.x+8,cursor.y+16),5.0f,IM_COL32(218,188,155,255),22);
            ImGui::SetCursorPosX(ImGui::GetCursorPosX()+20);
            if(g_FontMain) ImGui::PushFont(g_FontMain); ImGui::TextUnformatted("VANTA / GD"); if(g_FontMain) ImGui::PopFont();
            ImGui::SameLine(); ImGui::SetCursorPosY(ImGui::GetCursorPosY()+5);
            LightLabel("  НАСТРОЙКИ ИГРЫ");
            ImGui::SameLine(ww-61); ImGui::SetCursorPosY(11);
            if(ImGui::Button("x",ImVec2(39,39))) g_ShowMenu=false;
            ImGui::Spacing(); ImGui::Separator(); ImGui::Spacing();
            float panelY=ImGui::GetCursorPosY();
            float panelHeight=std::max(170.0f,hh-panelY-20.0f);
            ImGui::BeginChild("##side",ImVec2(179.0f,panelHeight),false,ImGuiWindowFlags_NoScrollbar);
            LightLabel("РАЗДЕЛЫ"); ImGui::Spacing();
            NavItem("##nav0","Игра",0,dt);
            NavItem("##nav1","Эффекты",1,dt);
            NavItem("##nav2","Настройки",2,dt);
            ImGui::SetCursorPosY(std::max(ImGui::GetCursorPosY(),panelHeight-57));
            ImGui::Separator(); LightLabel("v4.0  |  ARM64");
            ImGui::EndChild();
            ImGui::SameLine();
            ImGui::BeginChild("##main",ImVec2(0,panelHeight),false);
            ImGui::PushStyleVar(ImGuiStyleVar_Alpha,ImGui::GetStyle().Alpha * (0.54f + .46f*Smooth(g_TabBlend)));
            ImGui::SetCursorPosY(ImGui::GetCursorPosY()+10*(1-Smooth(g_TabBlend)));
            if(g_Tab==0) {
                SectionTitle("Игра","Проверка и управление уровнем");
                PrettySwitch("##noclip","Noclip","Для тестирования сложных участков",&g_Noclip,0,dt,hk_DestroyPlayer.active);
                PrettySwitch("##respawn","Быстрый рестарт","Перезапуск сразу после смерти",&g_InstantRespawn,1,dt,hk_ResetLevel.active);
                ImGui::Spacing(); LightLabel("СКОРОСТЬ ИГРЫ");
                ImGui::PushItemWidth(-1);
                ImGui::SliderFloat("##speed",&g_Speed,.25f,3.0f,"%.2fx");
                if(ImGui::IsItemDeactivatedAfterEdit()) SaveConfig();
                ImGui::PopItemWidth();
                float pw=(ImGui::GetContentRegionAvail().x-27)/4;
                SpeedPreset("0.5x",.5f,pw); ImGui::SameLine();
                SpeedPreset("1.0x",1.0f,pw); ImGui::SameLine();
                SpeedPreset("1.5x",1.5f,pw); ImGui::SameLine();
                SpeedPreset("2.0x",2.0f,pw);
                ImGui::Spacing(); LightLabel("ГОТОВЫЕ ПРОФИЛИ");
                float aw=(ImGui::GetContentRegionAvail().x-18)/3;
                if(ImGui::Button("Обычный",ImVec2(aw,43))) ApplyPreset(0); ImGui::SameLine();
                if(ImGui::Button("Фокус",ImVec2(aw,43))) ApplyPreset(1); ImGui::SameLine();
                if(ImGui::Button("Без FX",ImVec2(aw,43))) ApplyPreset(2);
            } else if(g_Tab==1) {
                SectionTitle("Эффекты","Меньше лишних визуальных эффектов");
                PrettySwitch("##fps","Счётчик FPS","Частота кадров поверх игры",&g_ShowFPS,2,dt);
                PrettySwitch("##timer","Таймер попытки","Время от начала попытки",&g_ShowTimer,3,dt);
                PrettySwitch("##deaths","Счётчик смертей","За текущий запуск игры",&g_ShowDeaths,4,dt);
                PrettySwitch("##shake","Без тряски камеры","Убирает тряску камеры",&g_NoShake,5,dt,hk_ShakeCamera.active);
                PrettySwitch("##mirror","Без зеркального экрана","Отключает переворот экрана",&g_NoMirror,6,dt,hk_ToggleFlipped.active);
                PrettySwitch("##deathfx","Без взрыва при смерти","Убирает эффект гибели",&g_NoDeathFX,7,dt,hk_DeathEffect.active);
                PrettySwitch("##particles","Убрать частицы","Меньше эффектов и нагрузки",&g_NoParticles,8,dt,hk_ParticleUpdate.active);
                if(PrettySwitch("##trailoff","Скрыть след","Без следа за персонажем",&g_NoTrail,9,dt,hk_ActivateStreak.active)) {if(g_NoTrail)g_AlwaysTrail=false;SaveConfig();}
                if(PrettySwitch("##trailon","Постоянный след","След виден всегда",&g_AlwaysTrail,10,dt,hk_DeactStreak.active)) {if(g_AlwaysTrail)g_NoTrail=false;SaveConfig();}
            } else if(g_Tab==2) {
                SectionTitle("Настройки","Внешний вид и поведение оверлея");
                PrettySwitch("##motion","Меньше анимаций","Переходы без плавного движения",&g_ReducedMotion,12,dt);
                PrettySwitch("##hudright","HUD справа","FPS и таймер у правого края",&g_HudRight,13,dt);
                LightLabel("ПРОЗРАЧНОСТЬ МЕНЮ");
                ImGui::PushItemWidth(-1); ImGui::SliderFloat("##opacity",&g_MenuOpacity,.65f,1.0f,"%.2f");
                if(ImGui::IsItemDeactivatedAfterEdit()) SaveConfig();
                ImGui::Spacing(); LightLabel("РАЗМЕР КНОПКИ");
                ImGui::SliderFloat("##size",&g_CircleRadius,24,48,"%.0f px");
                if(ImGui::IsItemDeactivatedAfterEdit()) SaveConfig();
                ImGui::PopItemWidth(); ImGui::Spacing();
                if(ImGui::Button("Кнопку в центр",ImVec2(ImGui::GetContentRegionAvail().x,42))) {g_CircleX=g_ScreenW*.5f;g_CircleY=g_ScreenH*.5f;SaveConfig();}
                if(ImGui::Button("Сброс настроек",ImVec2(ImGui::GetContentRegionAvail().x,42))) RestoreDefaults();
                ImGui::Spacing(); LightLabel("Кнопку можно перетаскивать и нажимать.");
                LightLabel("Все изменения сохраняются автоматически.");
            }
            ImGui::PopStyleVar();
            ImGui::EndChild();
        }
        ImGui::End(); ImGui::PopStyleColor(); ImGui::PopStyleVar();
    }
    ImGui::Render(); ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());
}

EGLBoolean hook_eglSwapBuffers(EGLDisplay dpy, EGLSurface surface) {
    EGLint w = 0, h = 0;
    if (p_eglQuerySurface) {
        p_eglQuerySurface(dpy, surface, EGL_WIDTH, &w);
        p_eglQuerySurface(dpy, surface, EGL_HEIGHT, &h);
    }
    if (!g_Init) {
        if (w <= 0 || h <= 0) { w = 2376; h = 1080; }
        g_ScreenW = (float)w; g_ScreenH = (float)h;
        ImGui::CreateContext();
        ImGuiIO& io = ImGui::GetIO();
        io.IniFilename = nullptr;
        io.DisplaySize = ImVec2(g_ScreenW, g_ScreenH);
        LoadCrispFonts();
        ApplyObsidianStyle();
        ImGui_ImplOpenGL3_Init("#version 300 es");
        g_LastTime = GetNowSeconds();
        g_Init = true;
    }
    ImGuiIO& io = ImGui::GetIO();
    if (w > 0 && h > 0) { g_ScreenW = (float)w; g_ScreenH = (float)h; io.DisplaySize = ImVec2(g_ScreenW, g_ScreenH); }
    double now = GetNowSeconds();
    float dt = (float)(now - g_LastTime);
    if (dt <= 0.0f || dt > 0.25f) dt = 1.0f / 60.0f;
    io.DeltaTime = dt;
    g_LastTime = now;

    DrawMenu(dt);

    hk_eglSwapBuffers.restore();
    EGLBoolean res = p_eglSwapBuffers(dpy, surface);
    hk_eglSwapBuffers.reenable();
    return res;
}

void* InitThread(void*) {
    g_RngState ^= (uint32_t)time(NULL);
    LoadConfig();

    void* egl_lib = dlopen("libEGL.so", RTLD_NOLOAD | RTLD_NOW);
    if (!egl_lib) egl_lib = dlopen("/system/lib64/libEGL.so", RTLD_NOW);
    p_eglSwapBuffers = (PFN_eglSwapBuffers)(egl_lib ? dlsym(egl_lib, "eglSwapBuffers") : dlsym(RTLD_DEFAULT, "eglSwapBuffers"));
    p_eglQuerySurface = (PFN_eglQuerySurface)(egl_lib ? dlsym(egl_lib, "eglQuerySurface") : dlsym(RTLD_DEFAULT, "eglQuerySurface"));
    if (p_eglSwapBuffers) hk_eglSwapBuffers.install((void*)p_eglSwapBuffers, (void*)hook_eglSwapBuffers);

    for (int i = 0; i < 40; i++) {
        dl_iterate_phdr(ScanPhdrCallback, nullptr);
        if (p_TouchesBegin && g_CocosBase) break;
        usleep(150000);
    }

    if (g_CocosBase) {

        if (!p_DestroyPlayer && OFF_DESTROY_PLAYER)   p_DestroyPlayer   = (PFN_DestroyPlayer)(g_CocosBase + OFF_DESTROY_PLAYER);
        if (!p_ResetLevel && OFF_RESET_LEVEL)         p_ResetLevel      = (PFN_ResetLevel)(g_CocosBase + OFF_RESET_LEVEL);
        if (!p_OnQuit && OFF_ON_QUIT)                 p_OnQuit          = (PFN_OnQuit)(g_CocosBase + OFF_ON_QUIT);
        if (!p_GameUpdate && OFF_GAME_UPDATE)         p_GameUpdate      = (PFN_GameUpdate)(g_CocosBase + OFF_GAME_UPDATE);
        if (!p_ToggleFlipped && OFF_TOGGLE_FLIPPED)   p_ToggleFlipped   = (PFN_ToggleFlipped)(g_CocosBase + OFF_TOGGLE_FLIPPED);
        if (!p_ShakeCamera && OFF_SHAKE_CAMERA)       p_ShakeCamera     = (PFN_ShakeCamera)(g_CocosBase + OFF_SHAKE_CAMERA);
        if (!p_DeathEffect && OFF_DEATH_EFFECT)       p_DeathEffect     = (PFN_DeathEffect)(g_CocosBase + OFF_DEATH_EFFECT);
        if (!p_ActivateStreak && OFF_ACTIVATE_STREAK) p_ActivateStreak  = (PFN_ActivateStreak)(g_CocosBase + OFF_ACTIVATE_STREAK);
        if (!p_DeactStreak && OFF_DEACT_STREAK)       p_DeactStreak     = (PFN_DeactStreak)(g_CocosBase + OFF_DEACT_STREAK);
        if (!p_SchedulerUpdate && OFF_SCHEDULER_UPDATE) p_SchedulerUpdate = (PFN_SchedulerUpdate)(g_CocosBase + OFF_SCHEDULER_UPDATE);
        if (!p_ParticleUpdate && OFF_PARTICLE_UPDATE) p_ParticleUpdate  = (PFN_ParticleUpdate)(g_CocosBase + OFF_PARTICLE_UPDATE);
    }

    if (p_TouchesBegin)   hk_TouchesBegin.install((void*)p_TouchesBegin, (void*)hook_TouchesBegin);
    if (p_TouchesMove)    hk_TouchesMove.install((void*)p_TouchesMove, (void*)hook_TouchesMove);
    if (p_TouchesEnd)     hk_TouchesEnd.install((void*)p_TouchesEnd, (void*)hook_TouchesEnd);
    if (p_TouchesCancel)  hk_TouchesCancel.install((void*)p_TouchesCancel, (void*)hook_TouchesCancel);

    if (p_DestroyPlayer)   hk_DestroyPlayer.install((void*)p_DestroyPlayer, (void*)hook_DestroyPlayer);
    if (p_ResetLevel)      hk_ResetLevel.install((void*)p_ResetLevel, (void*)hook_ResetLevel);
    if (p_OnQuit)          hk_OnQuit.install((void*)p_OnQuit, (void*)hook_OnQuit);
    if (p_GameUpdate)      hk_GameUpdate.install((void*)p_GameUpdate, (void*)hook_GameUpdate);
    if (p_ToggleFlipped)   hk_ToggleFlipped.install((void*)p_ToggleFlipped, (void*)hook_ToggleFlipped);
    if (p_ShakeCamera)     hk_ShakeCamera.install((void*)p_ShakeCamera, (void*)hook_ShakeCamera);
    if (p_DeathEffect)     hk_DeathEffect.install((void*)p_DeathEffect, (void*)hook_DeathEffect);
    if (p_ActivateStreak)  hk_ActivateStreak.install((void*)p_ActivateStreak, (void*)hook_ActivateStreak);
    if (p_DeactStreak)     hk_DeactStreak.install((void*)p_DeactStreak, (void*)hook_DeactStreak);
    if (p_SchedulerUpdate) hk_SchedulerUpdate.install((void*)p_SchedulerUpdate, (void*)hook_SchedulerUpdate);
    if (p_ParticleUpdate)  hk_ParticleUpdate.install((void*)p_ParticleUpdate, (void*)hook_ParticleUpdate);

    FileLog("VANTA hooks DP=%d RL=%d GU=%d",hk_DestroyPlayer.active,hk_ResetLevel.active,hk_GameUpdate.active);
    return nullptr;
}

__attribute__((constructor))
void EntryPoint() {
    FileLog("=== libgdmenu.so VANTA 5 loaded ===");
    pthread_t t;
    pthread_create(&t, nullptr, InitThread, nullptr);
}
