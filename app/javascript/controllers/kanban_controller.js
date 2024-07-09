import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['column', 'item'];

  itemTargetConnected(item) {
    // Find the kanban column this item should belong to.
    const parent = this.columnTargets.find((column) => {
      return column.dataset.status == item.dataset.status
    });

    if (!parent) {
      // If we don't fit in any kanban column, simply remove the item.
      // This will happen when a document goes to the archives section (status == paid)
      item.remove();
    } else if (parent != item.parentNode) {
      // If the status change, move to the proper column
      parent.prepend(item);
    }
  }
}
