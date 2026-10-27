// Page behaviour: package picker, dock demo, scroll reveals.
document.documentElement.classList.add('js');

// Package picker. Lists mirror packages/ and iso/packages/ in the repository.
const PACKAGES = {
  base: ['linux', 'linux-firmware', 'networkmanager', 'pipewire', 'wireplumber', 'bluez', 'sudo', 'Inter and Noto fonts'],
  desktop: ['labwc', 'quickshell', 'foot', 'thunar', 'swaybg', 'greetd'],
  normal: ['firefox', 'imv', 'mpv'],
  zengav: ['zengav'],
  zengsuite: ['zengsuite']
};
const picker = document.querySelector('[data-picker]');
if (picker) {
  const state = { edition: 'normal', zengav: false, zengsuite: false };
  const list = picker.querySelector('[data-packages]');
  const count = picker.querySelector('[data-count]');

  const render = () => {
    const groups = [['The system', PACKAGES.base], ['The Zolt desktop', PACKAGES.desktop]];
    if (state.edition === 'normal') groups.push(['Apps', PACKAGES.normal]);
    const add = [];
    if (state.zengav) add.push(...PACKAGES.zengav);
    if (state.zengsuite) add.push(...PACKAGES.zengsuite);
    if (add.length) groups.push(['Add-ons', add]);

    list.textContent = '';
    let total = 0;
    for (const [name, items] of groups) {
      const head = document.createElement('li');
      head.className = 'group';
      head.textContent = name;
      list.append(head);
      items.forEach((item, i) => {
        const li = document.createElement('li');
        li.textContent = item;
        li.style.animationDelay = `${Math.min(i * 25, 250)}ms`;
        if (name === 'Add-ons') li.className = 'new';
        list.append(li);
        total++;
      });
    }
    count.textContent = total;
  };

  picker.addEventListener('click', (e) => {
    const seg = e.target.closest('[data-edition]');
    const chip = e.target.closest('[data-addon]');
    if (seg) {
      state.edition = seg.dataset.edition;
      picker.querySelectorAll('[data-edition]').forEach((b) => {
        const on = b === seg;
        b.classList.toggle('is-on', on);
        b.setAttribute('aria-pressed', on);
      });
    } else if (chip) {
      const key = chip.dataset.addon;
      state[key] = !state[key];
      chip.setAttribute('aria-pressed', state[key]);
    } else return;
    render();
  });
  render();
}

// Dock demo: icons grow by distance from the pointer, like the real Zolt dock.
const dock = document.querySelector('[data-dock] .dock');
if (dock) {
  const apps = [...dock.querySelectorAll('.app')];
  const reset = () => apps.forEach((a) => (a.style.transform = ''));
  dock.addEventListener('pointermove', (e) => {
    for (const a of apps) {
      const r = a.getBoundingClientRect();
      const d = Math.abs(e.clientX - (r.left + r.width / 2));
      const s = 1 + 0.55 * Math.exp(-(d * d) / (2 * 55 * 55));
      a.style.transform = `scale(${s.toFixed(3)})`;
    }
  });
  dock.addEventListener('pointerleave', reset);
}

// Reveal sections as they scroll in.
const targets = document.querySelectorAll('main > section:not(.hero) h2, .lead, .edition, .picker, .zolt-copy p, .dock-demo, .shots figure, .addon-grid article, .dl, .status-grid > div, .build pre, .statement .big');
if ('IntersectionObserver' in window && !matchMedia('(prefers-reduced-motion: reduce)').matches) {
  const io = new IntersectionObserver((entries) => {
    for (const en of entries) if (en.isIntersecting) { en.target.classList.add('in'); io.unobserve(en.target); }
  }, { rootMargin: '0px 0px -8% 0px' });
  targets.forEach((el, i) => { el.classList.add('reveal'); el.style.setProperty('--d', `${(i % 3) * 70}ms`); io.observe(el); });
}
