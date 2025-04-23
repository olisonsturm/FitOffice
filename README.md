# FitOffice@DHBW

The original FitOffice@DHBW App. Made with ❤️ at DHBW Ravensburg.

## Docs
1. **Splash Screen anzeigen, bis Daten geladen sind, und nach dem Laden `FlutterNativeSplash.remove()` aufrufen:**  
   In diesem Fall wird es in der Methode `onReady()` der `AuthenticationRepository()` entfernt.
2. **Vor dem Start der App:**  
   Firebase initialisieren und nach der Initialisierung das `AuthenticationRepository` aufrufen, um zu überprüfen, welcher Bildschirm angezeigt werden soll.
3. **Lösung für Probleme mit `Get.lazyPut` und `Get.Put()`:**  
   Alle Controller werden in `InitialBinding` definiert.
4. **Bildschirmübergänge:**  
   Verwenden Sie diese zwei Eigenschaften in `GetMaterialApp`:  
      - `defaultTransition: Transition.leftToRightWithFade,`  
      - `transitionDuration: const Duration(milliseconds: 500),`
5. **HOME-BILDSCHIRM:**  
   - Zeigen Sie einen Fortschrittsindikator oder Splash Screen an, bis alle Daten aus der Cloud geladen sind.  
   - Lassen Sie das `AuthenticationRepository` entscheiden, welcher Bildschirm als erstes angezeigt wird.
6. **Authentication Repository:**  
   - Wird für die Benutzer-Authentifizierung und Bildschirmweiterleitungen verwendet.  
   - Wird beim Start der App aus `main.dart` aufgerufen.  
   - Die Methode `onReady()` setzt den `firebaseUser`-Zustand, entfernt den Splash Screen und leitet zum entsprechenden Bildschirm weiter.  
   - Nutzung in anderen Klassen: `[final auth = AuthenticationRepository.instance;]`
