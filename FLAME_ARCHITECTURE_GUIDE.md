// 🎮 FLAME 2D GAME ENGINE - MİMARİ KLAVUZU
// Professional-Grade Component-Based Game Development

/*
╔════════════════════════════════════════════════════════════════════════════╗
║                    FLAME GAME ARCHITECTURE OVERVIEW                       ║
╚════════════════════════════════════════════════════════════════════════════╝

📦 DIZIN YAPISI (Directory Structure):

lib/features/flame_game/
├── 📂 presentation/
│   └── pages/
│       └── flame_game_page.dart          (Flutter → Flame embed)
│
├── 📂 domain/entities/
│   └── game_constants.dart               (Constants + Enums + GameStats)
│
└── 📂 data/game/
    ├── main_game.dart                    (🔴 GAME LOOP - Core)
    │   ├── onLoad()                      (Initialization)
    │   ├── update(dt)                    (Logic Loop)
    │   ├── onTapDown()                   (Input)
    │   └── checkCollisions()             (Collision)
    │
    ├── 📂 components/
    │   ├── player.dart                   (🟢 Player - Gravity + Jump)
    │   └── obstacle.dart                 (🚧 Obstacle - Movement)
    │
    └── 📂 services/
        ├── physics_service.dart          (⚙️ Physics Calculations)
        └── collision_service.dart        (💥 Collision Detection)

═════════════════════════════════════════════════════════════════════════════

🎬 OYUN DÖNGÜSÜ (Game Loop) - GAME FLOW:

    ┌─────────────────────────────────┐
    │  MyApp.home = SplashScreen      │
    │  → Flutter UI Routes            │
    └─────────────────┬───────────────┘
                      │
                      ↓
    ┌─────────────────────────────────┐
    │  HomePage / HomeTabView         │
    │  → "🎮 Flame Oyna" Butonu       │
    └─────────────────┬───────────────┘
                      │
                      ↓
    ┌─────────────────────────────────┐
    │  FlameGamePage (Flutter)        │
    │  → GameWidget(game: FlappyGame) │
    └─────────────────┬───────────────┘
                      │
                      ↓
    ┌──────────────────────────────────┐
    │ FLAME ENGINE STARTS RUNNING     │
    │ ┌────────────────────────────────┤
    │ │1. onLoad()                     │
    │ │   - Player component oluştur  │
    │ │   - Camera setup               │
    │ │   - Game state = playing       │
    │ │                                │
    │ │2. UPDATE LOOP (every frame)   │
    │ │   Δt (delta time)              │
    │ │                                │
    │ │   a) Physics Engine            │
    │ │      - Gravity uygula          │
    │ │      - Velocity hesapla        │
    │ │      - Position update         │
    │ │                                │
    │ │   b) Input Handling            │
    │ │      - onTapDown() çağrı       │
    │ │      - player.jump()           │
    │ │                                │
    │ │   c) Spawn System              │
    │ │      - Obstacle spawn timer    │
    │ │      - Yeni obstacles ekle     │
    │ │                                │
    │ │   d) Collision Detection       │
    │ │      - Player ∩ Obstacle?      │
    │ │      - Game Over?              │
    │ │                                │
    │ │3. RENDER (otomatik)           │
    │ │   - Background renk            │
    │ │   - Tüm components çizilir    │
    │ │                                │
    │ │=> Repeat 60 FPS'de (16.67ms) │
    │ └────────────────────────────────┤
    │                                  │
    │ 4. Game Over Trigger             │
    │    - onGameOver() callback        │
    │    - Dialog göster               │
    │    - Restart veya exit           │
    └──────────────────────────────────┘

═════════════════════════════════════════════════════════════════════════════

🧩 COMPONENT-BASED ARCHITECTURE:

┌─────────────────────────────────────────┐
│         FlameGame (extends)             │
│     (onLoad, update, render)            │
├─────────────────────────────────────────┤
│ children = [Player, Obstacle1,          │
│            Obstacle2, ...]              │
└──────────────┬──────────────────────────┘
               │
       ┌───────┴────────────────┐
       ↓                        ↓
   ┌─────────────┐      ┌──────────────┐
   │   Player    │      │  Obstacle    │
   │ (Component) │      │ (Component)  │
   ├─────────────┤      ├──────────────┤
   │ • position  │      │ • position   │
   │ • size      │      │ • size       │
   │ • velocity  │      │ • speed      │
   │ • paint     │      │ • paint      │
   ├─────────────┤      ├──────────────┤
   │ + onLoad()  │      │ + onLoad()   │
   │ + update()  │      │ + update()   │
   │ + jump()    │      │ (moves left) │
   │ + collide() │      │ + collide()  │
   └─────────────┘      └──────────────┘

Flame'de TÜMLAMA (Composition) ön plandadır:
- Her component independenttir
- Kendi update/render mantığı vardır
- Collision callbacks'i vardır

═════════════════════════════════════════════════════════════════════════════

🌍 FİZİKS MOTORU (Physics Engine):

📐 Kinematik Denklemler:

  s(t) = s₀ + v₀t + ½at²     [Position]
  v(t) = v₀ + at             [Velocity]

ÖRNEK - Oyuncu Düşüşü:
  gravity = 800 px/s²
  dt = 0.016s (60 FPS'de)
  
  velocityY += gravity * dt
              = 0 + 800 * 0.016
              = 12.8 px/s
  
  position.y += velocityY * dt
               = 0 + 12.8 * 0.016
               = 0.2048 px (aşağı)

ÖRNEK - Zıplama (Parabolic Motion):
  Initial velocityY = -500 px/s (yukarı)
  Zıplama süresi = 0.5s
  
  progress = elapsed_time / duration
  jumpCurve = 1.0 - progress² (easing out)
  
  velocityY = -500 * jumpCurve
  
  t=0s   : velocityY = -500 (hızlı yukarı)
  t=0.25s: velocityY = -375 (yavaşlayan)
  t=0.50s: velocityY =    0 (zıplama bitti)

═════════════════════════════════════════════════════════════════════════════

💥 ÇARPIŞMA DETEKSİYONU (Collision Detection):

Flame'de iki yaklaşım:

1️⃣ AUTOMATIC (CollisionCallbacks - Önerilir):
   ✅ Built-in hitbox'lar
   ✅ Otomatik kontrol
   ✅ onCollisionStart(), onCollisionEnd() callbacks
   
   class Player extends ... with CollisionCallbacks {
     @override
     void onCollisionStart(Set<Vector2> intersection, CollisionArea ca) {
       // Player engele çarptı!
       gameRef.gameOver();
     }
   }

2️⃣ MANUAL (Physics Service):
   ✅ Özel mantık için
   ✅ Advanced physics
   ✅ Bounding box overlaps kontrolü
   
   bool isColliding = CollisionService.checkRectCollision(
     playerBounds,
     obstacleBounds,
   );

═════════════════════════════════════════════════════════════════════════════

🎮 INPUT HANDLING (Giriş Yönetimi):

Flame Events:
  • onTapDown(TapDownEvent)      - Ekrana dokunma
  • onTapUp(TapUpEvent)          - Dokunmayı kaldırma
  • onLongTapDown
  • onDragStart/Update/End

Örnek - Jump Trigger:
  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    
    if (gameState == GameState.playing) {
      player.jump();  // Player'ı zıplat
    }
  }

═════════════════════════════════════════════════════════════════════════════

🎨 RENDERING (Çizim):

Flame otomatik render eder (super.render() calls):

Order:
  1. backgroundColor() - Arka plan rengi
  2. Tüm components paint edilir
     └─ RectangleComponent.paint() → Canvas.drawRect()
  3. UI overlays (if any)

Performance Tips:
  ✅ RectangleComponent performanslıdır
  ✅ Karmaşık shapes yerine primitive shapes kullan
  ✅ Sprite loading sonraya bırak

═════════════════════════════════════════════════════════════════════════════

📊 OYUN İSTATİSTİKLERİ (Game Stats):

class GameStats {
  int score = 0;                 // Geçilen engellerin sayısı
  int obstaclesPassed = 0;       // Stat
  DateTime gameStartTime;        // Başlama zamanı
  Duration gameDuration;         // Toplam oyun süresi
  
  Duration get playTime => 
    gameDuration ?? DateTime.now().difference(gameStartTime);
}

Score Hesabı:
  - Her engel geçilince +10 puan
  - Çarpışmada -5 puan veya game over

═════════════════════════════════════════════════════════════════════════════

🚀 BAŞLAMA (Getting Started):

Adım 1: Pubspec.yaml:
  dependencies:
    flame: ^1.15.0

Adım 2: Flutter'dan Eriş:
  Navigator.of(context).pushNamed('/flame-game');
  
Adım 3: Oyunu Başlat:
  gameInstance = FlappyGame();
  // ✅ onLoad() otomatik çağrılır
  // ✅ Game loop başlar

Adım 4: Debug:
  player.debugPrint();
  gameInstance.printGameState();

═════════════════════════════════════════════════════════════════════════════

🔍 DEBUG İPUÇLARI:

1. Console Output:
   ✅ Logging statements - update() içinde
   ✔️ print('Frame: ${DateTime.now()}');
   
2. Visual Debug:
   ✅ FPS counter
   ✅ HitBox rendering
   
3. Game State:
   gameInstance.printGameState();

═════════════════════════════════════════════════════════════════════════════

📚 TIP & TRICKS:

❌ Flame Pitfalls:
   • Memory leaks - removeFromParent() çağrısını unutmak
   • Infinite loops - update(dt) içinde while
   • Asset loading - onLoad() sırasında yava
   • Collision spam - onCollisionStart() beraber

✅ Best Practices:
   • Component lifecycle'ı izle
   • hasGameRef mixin'i kullan
   • Reusable components oluştur
   • Physics calculations'ı service'lere koy

═════════════════════════════════════════════════════════════════════════════

🔗 RESSOURCES:

Official: https://flame-engine.org/
Docs: https://flame-engine.org/docs/
Community: Discord/GitHub

═════════════════════════════════════════════════════════════════════════════
*/
