{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  onEntrypointLoaded: async function(engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine();
    await appRunner.runApp();

    const loadingContainer = document.getElementById('loading-container');
    if (loadingContainer) {
      loadingContainer.style.opacity = '0';
      setTimeout(() => {
        if (loadingContainer && loadingContainer.parentNode) {
          loadingContainer.parentNode.removeChild(loadingContainer);
        }
      }, 350);
    }
  }
});
