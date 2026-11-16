# ICEIBank mobile

App Flutter, Android. Consome a mesma API das três agências e funciona offline-first.

## Rodar

```powershell
$env:Path = "C:\dev\flutter\bin;" + $env:Path
cd app_mobile
flutter pub get
flutter run
```

O emulador acessa as agências em `10.0.2.2` nas portas 4063, 4064 e 4065. Para outro host ou porta base:

```powershell
flutter run --dart-define=ICEI_HOST=192.168.0.10 --dart-define=ICEI_PORTA_BASE=4063
```

Em celular físico, o Flask precisa escutar na rede (`app.run(host="0.0.0.0", ...)`) e o IP do computador precisa entrar em `android/app/src/main/res/xml/network_security_config.xml`.

## No navegador (Brave, Edge ou Chrome)

Sem Android Studio. O banco local usa IndexedDB e o sqlite3.wasm de `web/`.

```powershell
flutter build web --release
python -m http.server 5000 --directory build/web
```

Abra `http://localhost:5000`. Para ver como celular: F12, depois Ctrl+Shift+M e escolha um Pixel. Para simular modo avião: F12, aba Network, marque Offline.

## Código gerado

O banco local usa drift. Depois de mudar tabelas em `lib/dados/banco.dart`:

```powershell
dart run build_runner build
```

## Testes

```powershell
flutter analyze
flutter test
```

Os testes cobrem a fila offline, a sincronização com conflito, o painel de liderança e o fluxo completo de login, depósito offline, reconexão e resolução de conflito.
