import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { hash } from "@ember/helper";
import { action } from "@ember/object";
import { service } from "@ember/service";
import icon from "discourse/helpers/d-icon";
import {
  listColorSchemes,
  loadColorSchemeStylesheet,
  updateColorSchemeCookie,
} from "discourse/lib/color-scheme-picker";
import cookie from "discourse/lib/cookie";
import ColorPalettePicker from "select-kit/components/color-palette-picker";

export default class SidebarThemeToggle extends Component {
  @service site;
  @service currentUser;
  @service session;
  @service interfaceColor;

  @tracked anonColorPaletteId = this.#loadAnonColorPalette();
  @tracked userColorPaletteId = this.session.userColorSchemeId;
  @tracked selectedColorPaletteId = null;

  get userSelectableThemes() {
    return listColorSchemes(this.site);
  }

  get hasThemes() {
    return this.userSelectableThemes?.length > 1;
  }

  #loadAnonColorPalette() {
    const storedAnonPaletteId = cookie("color_scheme_id");
    if (storedAnonPaletteId) {
      return parseInt(storedAnonPaletteId, 10);
    }
  }

  get currentPaletteId() {
    return (
      this.selectedColorPaletteId ||
      this.userColorPaletteId ||
      this.anonColorPaletteId
    );
  }

  @action
  async setTheme(colorSchemeId) {
    this.interfaceColor.forceLightMode();
    await Promise.all([
      loadColorSchemeStylesheet(colorSchemeId, null, true),
      loadColorSchemeStylesheet(colorSchemeId, null),
    ]);
    this.selectedColorPaletteId = colorSchemeId;
    updateColorSchemeCookie(colorSchemeId);
    updateColorSchemeCookie(colorSchemeId, {
      dark: true,
    });
    this.site?.appEvents?.trigger("sidebar-colorscheme-toggled");
  }

  <template>
    {{#if this.hasThemes}}
      <div class="sidebar-colorscheme-toggle__wrapper">
        {{icon settings.toggle_icon}}

        <ColorPalettePicker
          @content={{this.userSelectableThemes}}
          @value={{this.currentPaletteId}}
          @onChange={{this.setTheme}}
          class="sidebar-colorscheme-toggle-dropdown"
          {{!-- @options={{hash placementStrategy="absolute" placement="top-start"}} --}}
        />
      </div>
    {{/if}}
  </template>
}
