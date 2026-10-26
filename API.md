# TabView API

## Lifecycle

### `tabview.init()`

Initializes `tabview`

**Caution**: Awaiting to call from `vis.events.INIT`

**Example**:

```lua
vis.events.subscribe(vis.events.INIT, function()
  tabview.init()
end)
```


### `tabview.terminate()`

Closes all tabs

**Caution**: required to call from `vis.events.QUIT`

**Example**:

```lua
vis.events.subscribe(vis.events.QUIT, function()
  tabview.terminate()
end)
```

## Tab actions

### `tabview.tab_open(filename, index)`

Opens new tab

**Arguments**:

- `filename`: `string` - filename to open
- `index`:
  - `number`- Replace `index` tab
  - `nil` - Open new tab

### `tabview.tab_close(arg)`

Closes tab

**Arguments**:

- `arg`: `number` | `string` | `nil`
  - `number`: close tab at index
  - `string`: close tab with name (full)
  - `nil`: close current tab

## Events

### `tabview.events.TAB_OPEN`

**Signature**: `tab_open(filename)`

### `tabview.events.TAB_REPLACE`

**Signature**: `tab_replace(filename, idx)`

### `tabview.events.TAB_CLOSE`

**Signature**: `tab_close(idx)`

## Commands

### `:open <filename>`

**Overriden**

Now opens file to new tab.

### `:tabcount`

Displays tab count (*Right where you typed that*)

### `:closetab`

Closes current tab

### `:nexttab` / `:prevtab`

Switches to next/previous tab

## Getters

### `tabview.active_window()`

Get active window, where tabs changes

### `tabview.get_active_tab()`

Get active tab index

### `tabview.get_tab_count()`

Get tab count

### `tabview.get_tab_name_at(index)`

Get tab name

**Arguments**:
- `index`: `number` | `nil`
  - `number`: returns name of `index` tab
  - `nil`: returns name of current tab

**Returns**:

- `string` - tab name (Full path, or whatever you pass to open this tab)
- `nil` - tab not found

## Recommendations

There is mine tab mappings for this plugin

```lua
-- List throw tabs
vis:map(vis.modes.NORMAL, "th", function() vis:command("prevtab") end)
vis:map(vis.modes.NORMAL, "tl", function() vis:command("nexttab") end)
-- Closes tab, like :q!
vis:map(vis.modes.NORMAL, "tq", function() vis:command("closetab") end)
```
