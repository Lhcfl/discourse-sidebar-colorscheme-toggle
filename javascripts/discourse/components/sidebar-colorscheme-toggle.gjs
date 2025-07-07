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
import ComboBox from "select-kit/components/combo-box";

export default class SidebarThemeToggle extends Component {
  @service site;
  @service currentUser;
  @service session;

  @tracked anonColorPaletteId = this.#loadAnonColorPalette();
  @tracked userColorPaletteId = this.session.userColorSchemeId;
  @tracked selectedColorPaletteId = null;

  @tracked availableThemes = listColorSchemes(this.site);
  @tracked hasThemes = this.availableThemes?.length > 1;

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
  setTheme(id) {
    loadColorSchemeStylesheet(id, null, true);
    updateColorSchemeCookie(id);
    this.site?.appEvents?.trigger("sidebar-colorscheme-toggled");
  }

  <template>
    {{#if this.hasThemes}}
      <div class="sidebar-colorscheme-toggle__wrapper">
        {{icon settings.toggle_icon}}

        <ComboBox
          @content={{this.availableThemes}}
          @value={{this.currentPaletteId}}
          @onChange={{action "setTheme"}}
          class="sidebar-colorscheme-toggle-dropdown"
          @options={{hash placementStrategy="absolute" placement="top-start"}}
        />
      </div>
    {{/if}}
  </template>
}
