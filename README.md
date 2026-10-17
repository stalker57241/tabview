# Tabview

Allows to edit multiple tabs independantly.

**Caution**: consumes new windows if it haven't assigned `owner` property

# Available commands

- `:open <filename>` creates new tab. (Override)
- `:nexttab` opens next tab
- `:prevtab` opens previous tab. Tabs is cycled
- `:tabcount` shows tab count. Duplicate proofed
- `:closetab` closes current tab, cancelling changes
  - Don't forget to save it.

# Events

## `TabView`.events.TAB_OPEN

*also known as `tab_open(filepath)`*

Emit to open tab, and emits when tab opened. Alternative call: `TabView`.`tab_open(filepath)`

## `TabView`.events.TAB_CLOSE

*also known as `tab_close(idx)`*

Emit to close tab with index, and emits when that tab closed. Alternative call: **`WIP`**

# Recommendations

There is interesting variants to bind it:

```lua
-- View active tab count
vis:map(vis.modes.NORMAL, "<C-t>t", function() vis:command("tabcount") end)
-- List tabs
vis:map(vis.modes.NORMAL, "<C-t>h", function() vis:command("prevtab") end)
vis:map(vis.modes.NORMAL, "<C-t>l", function() vis:command("nexttab") end)
-- Closes tab, like :q!
vis:map(vis.modes.NORMAL, "<C-t>q!", function() vis:command("closetab") end)
```

# Dependants

## [TreeView](https://github.com/stalker57241/treeview)

- Optional

Now file selection opens a new tab.

# Future ideas

- [ ] Add `:wt <filename|idx>` to save changes fpr specified tab
- [ ] Add `:wtall` to save all changes for tabs.
- [ ] Add tabs for each window
