import Component from "@glimmer/component";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
import {
  listColorSchemes,
  loadColorSchemeStylesheet,
  updateColorSchemeCookie,
} from "discourse/lib/color-scheme-picker";

export default class SidebarColorschemeToggle extends Component {
  @service site;
  @service currentUser;
  @tracked availableThemes = listColorSchemes(this.site);
  @tracked hasThemes = this.availableThemes?.length > 1;

  @action
  setTheme(colorshemeId) {
    loadColorSchemeStylesheet(colorshemeId, "", true);
    updateColorSchemeCookie(colorshemeId);
    this.site?.appEvents?.trigger("sidebar-colorscheme-toggled");
  }
}
