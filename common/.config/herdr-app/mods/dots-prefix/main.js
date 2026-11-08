import { View, div } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { closeOverlay, focused, hc, nextCommand, openOverlay, panes, props, run, spaces, theme } from "herdr";

// Les raccourcis de common/.config/tmux/tmux.conf, au préfixe près : C-Space,
// puis une touche. Tiré du mod « Tmux prefix » de herdrdev
// (github.com/herdrdev/herdr-layout-examples, tmux-prefix), BINDINGS refait
// sur notre tmux.conf : v/s pour les splits, hjkl pour les panes.
//
// Une action répétable laisse REPEAT_MS pour la refaire sans repasser par le
// préfixe, comme `bind -r` dans tmux.
const PREFIX = "ctrl+space";
const REPEAT_MS = 500;
const BINDINGS = [
  ["v", "Split à droite", "pane.split", { direction: "right" }],
  ["s", "Split en bas", "pane.split", { direction: "down" }],
  ["%", "Split à droite", "pane.split", { direction: "right" }],
  ['"', "Split en bas", "pane.split", { direction: "down" }],
  ["h", "Pane à gauche", "pane.go", { direction: "left" }, true],
  ["j", "Pane en bas", "pane.go", { direction: "down" }, true],
  ["k", "Pane en haut", "pane.go", { direction: "up" }, true],
  ["l", "Pane à droite", "pane.go", { direction: "right" }, true],
  ["left", "Pane à gauche", "pane.go", { direction: "left" }, true],
  ["down", "Pane en bas", "pane.go", { direction: "down" }, true],
  ["up", "Pane en haut", "pane.go", { direction: "up" }, true],
  ["right", "Pane à droite", "pane.go", { direction: "right" }, true],
  ["H", "Échanger à gauche", "pane.swap", { direction: "left" }, true],
  ["J", "Échanger en bas", "pane.swap", { direction: "down" }, true],
  ["K", "Échanger en haut", "pane.swap", { direction: "up" }, true],
  ["L", "Échanger à droite", "pane.swap", { direction: "right" }, true],
  ["c", "Nouvel onglet", "tab.new"],
  ["x", "Fermer le pane", "pane.close"],
  ["&", "Fermer l'onglet", "tab.close"],
  ["z", "Zoomer le pane", "pane.zoom"],
  ["n", "Onglet suivant", "tab.next", {}, true],
  ["p", "Onglet précédent", "tab.prev", {}, true],
  [",", "Renommer l'onglet", "tab.rename"],
  ["$", "Renommer l'espace", "space.rename"],
  [")", "Espace suivant", "space.next", {}, true],
  ["(", "Espace précédent", "space.prev", {}, true],
  ["w", "Chercher (picker)", "mod.open", { name: "picker" }],
  // Le dialogue du mod worktree n'a pas de commande : `worktree` l'ouvre comme
  // le bouton « + » des onglets (mods/new-menu), voir openWorktree.
  ["W", "Nouveau worktree", "worktree", { action: "new" }],
  ["o", "Ouvrir un worktree", "worktree", { action: "open" }],
  ["d", "Réduire la fenêtre", "window.minimize"],
  // base-index 1, comme dans tmux.conf : 1 est le premier onglet.
  ...Array.from({ length: 9 }, (_, i) => [String(i + 1), `Onglet ${i + 1}`, "tab.select", { index: i + 1 }]),
];

function openWorktree(action) {
  const space = spaces().find((s) => s.active);
  if (!space) return;
  const size = action === "open" ? { width: 560, height: 480 } : { width: 460, height: 280 };
  openOverlay({ mod: "worktree", kind: "dialog", ...size, props: { space: space.id, folder: panes().find((p) => p.focused)?.cwd, action } });
}

function forwardKey(e, key) {
  if (["enter", "tab", "backspace", "left", "right", "up", "down", "space"].includes(e.key)) return e.key;
  if (key === " ") return "space";
  if (/^[A-Z]$/.test(key)) return `shift+${key.toLowerCase()}`;
  if (key.length === 1 && "abcdefghijklmnopqrstuvwxyz0123456789`\\[],=-.';/".includes(key)) return key === "\\" ? "backslash" : key;
  return null;
}

export default class DotsPrefix extends View {
  init(_props, cx) {
    this.handle = cx.focus_handle();
    this.handle.focus();
    this.repeat = false;
    this.generation = 0;
    this.all = false;
    // La section mod:dots-prefix de keys.json gagne sur l'ouvreur global tant
    // que le popup est ouvert : C-Space C-Space arrive ici.
    cx.spawn(async (cx) => {
      for (;;) {
        await nextCommand();
        this.send(PREFIX, cx);
      }
    });
  }

  dismiss() {
    closeOverlay(props().overlay);
  }

  send(key, cx) {
    this.generation++;
    const terminal = focused()?.terminal;
    if (!terminal) return this.dismiss();
    // hc part à l'appel, avant que la fermeture n'annule les tâches de la vue.
    const pending = hc(["keys", terminal, key]);
    cx.spawn(async () => {
      const result = await pending;
      if (result.code !== 0) console.log(`dots-prefix: ${result.stderr}`);
    });
    this.dismiss();
  }

  key(e, cx) {
    cx.stop_propagation();
    const m = e.modifiers;
    if (e.key === "escape") return this.dismiss();
    if (m.control && e.key === "space") return this.send(PREFIX, cx);
    const plain = !m.control && !m.alt && !m.platform;
    const key = plain ? (e.key_char ?? (m.shift && e.key.length === 1 ? e.key.toUpperCase() : e.key)) : e.key;
    if (plain && key === "?") {
      this.all = !this.all;
      this.repeat = false;
      this.generation++;
      cx.notify();
      return;
    }
    const binding = plain && BINDINGS.find((b) => b[0] === key);
    if (!binding) {
      const forwarded = this.repeat && plain && forwardKey(e, key);
      if (forwarded) return this.send(forwarded, cx);
      return this.dismiss();
    }
    const [, , command, args = {}, repeatable = false] = binding;
    if (!repeatable) this.dismiss();
    if (command === "worktree") return openWorktree(args.action);
    run(command, args);
    if (repeatable) {
      this.repeat = true;
      const generation = ++this.generation;
      cx.timer.after(REPEAT_MS, () => {
        if (this.generation === generation) this.dismiss();
      });
      cx.notify();
    }
  }

  render() {
    const t = theme();
    const hidden = (key) => ["left", "right", "up", "down", "%", '"'].includes(key) || /^\d$/.test(key);
    const rows = this.all ? BINDINGS : BINDINGS.filter(([key]) => !hidden(key));
    return v_flex().id("dots-prefix").track_focus(this.handle)
      .on_key_down((e, cx) => this.key(e, cx))
      .p(14).gap(8).bg(t.popover).text_color(t.foreground).text_size(12)
      .child(h_flex().justify_between()
        .child(div().font_semibold().text_color(t.accent).child(this.repeat ? `Encore · ${REPEAT_MS} ms` : "C-Space · une touche"))
        .child(div().text_color(t.muted).child("Esc annule · C-Space l'envoie")))
      .child(v_flex().h(290).min_h(0).overflow_y_scrollbar().children(rows.map(([key, label, , , repeatable]) =>
        h_flex().h(20).flex_none().items_center().gap(12).child(div().w(40).text_color(t.accent).child(key))
          .child(div().flex_1().child(label)).child(div().text_color(t.dim).child(repeatable ? "répète" : "")))))
      .child(div().text_color(t.muted).child("1–9 onglets · flèches · ? tout voir"));
  }
}
