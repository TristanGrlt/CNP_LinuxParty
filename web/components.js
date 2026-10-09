class SiteHeader extends HTMLElement {
  connectedCallback() {
    const currentPath =
      window.location.pathname.split("/").pop() || "index.html";
    const isVisuels =
      currentPath === "visuels.html" ? "underline text-underline-offset-4" : "";
    const isDocs =
      currentPath === "docs.html" ? "underline text-underline-offset-4" : "";
    const isPropos =
      currentPath === "propos.html" ? "underline text-underline-offset-4" : "";
    const isIndex =
      currentPath === "index.html" || currentPath === ""
        ? "underline text-underline-offset-4"
        : "";

    this.innerHTML = `
            <nav class="border-b-2 border-offblack bg-offwhite sticky top-0 z-50">
                <div class="max-w-5xl mx-auto px-4 py-4 flex flex-wrap items-center justify-between gap-4 font-mono text-sm">
                    <a href="index.html" class="font-bold text-base tracking-tight uppercase hover:opacity-75">
                        >_ CNP Linux Party
                    </a>
                    <div class="flex flex-wrap items-center gap-6 font-bold">
                        <a href="index.html" class="hover:underline ${isIndex}">Accueil</a>
                        <a href="visuels.html" class="hover:underline ${isVisuels}">Visuels</a>
                        <a href="docs.html" class="hover:underline ${isDocs}">Documentation</a>
                        <a href="propos.html" class="hover:underline ${isPropos}">À propos</a>
                    </div>
                </div>
            </nav>
        `;
  }
}
customElements.define("site-header", SiteHeader);

class SiteFooter extends HTMLElement {
  connectedCallback() {
    this.innerHTML = `
            <footer class="border-t-2 border-offblack bg-white py-8 mt-auto flex flex-col items-center font-mono text-sm">
                <div class="flex items-center justify-center gap-8 mb-6">
                    <a href="index.html" title="Ceci n'est pas une Linux Party">
                        <img src="../visuels/logo/logo.png" alt="Logo CNP Linux Party" class="h-20 md:h-24 w-auto">
                    </a>
                    <a href="https://atacc.org" target="_blank" rel="noopener noreferrer" title="Association ATACC">
                        <img src="../visuels/image/atacc_logo.svg" alt="Logo ATACC" class="h-16 md:h-20 w-auto">
                    </a>
                </div>
                <p class="font-bold">© 2026 - Ceci n'est pas une Linux Party.</p>
                <p class="text-xs opacity-70 mt-2">Initié par les étudiants des Masters Informatique.</p>
            </footer>
        `;
  }
}
customElements.define("site-footer", SiteFooter);
