# Tabview

Allows to edit multiple tabs independantly.

**Caution**: consumes new windows if it haven't assigned `owner` property

# Installation & Usage

To download it:

```sh
git clone https://github.com/stalker57241/tabview ~/.config/vis/plugins/tabview
```

## Usage

Add to `visrc.lua`
```lua
local tabview = require('plugins/tabview')
-- If installed throw vis-plug
local tabview = plug.plugins.tabview

vis.events.subscribe(vis.events.INIT, function()
  tabview.init()
end)
```

# Frontends

- [TabDisplay](https://github.com/stalker57241/tabdisplay)

If you created your own frontend for `tabview`, pr here adding link to bottom of this list.

# Available commands

- `:open <filename>` creates new tab. *Overriden*
- `:nexttab` / `:prevtab`: opens next/previous tab. Tabs is cycled
- `:tabcount` shows tab count. Duplicate proof
- `:closetab` closes current tab, cancelling changes
  - Don't forget to save them.

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

### Marks:
- *Optional*: Optionally depends of this plugin
- *Required*: Depends of this plugin

## [`TabDisplay`](https://github.com/stalker57241/tabdisplay)

- *Required*

**Changes**:
Adds ui for listing tabs, using `API`

## [`TreeView`](https://github.com/stalker57241/treeview)

- *Optional*

**Changes**:
Now file selection opens a new tab.

# Future ideas

- [X] Add frontend for this plugin ([`TabDisplay`](https://github.com/stalker57241/tabdisplay))
- [ ] Add `:wt <filename|idx>` to save changes fpr specified tab
- [ ] Add `:wtall` to save all changes for tabs.
- [ ] Add tabs for each window

# For developers

API available [`here`](https://github.com/stalker57241/tabview/blob/general/API.md)
