/**
 * Module: Property-list utilities.
 *
 * Defines helpers for reading, updating, combining, and validating flat
 * property lists in the form `[key0, value0, key1, value1, ...]`.
 */
use <functions.scad>

/**
   ─────────────────────────────────────────────────────────────────────────────
   plist_is
   ─────────────────────────────────────────────────────────────────────────────

   Check whether a value has the structure of a property list.

   A property list is an even-length list in which every even-indexed element
   is a string key. The empty list is a valid property list. Values and duplicate
   keys are not otherwise restricted.

   **Parameters:**

   `value`: Value to check.

   **Returns:**

   `true` when `value` has property-list structure; otherwise `false`.

   **Examples:**

   ```scad
   plist_is(["size", [5, 10], "dia", 4]); // -> true
   plist_is([]);                            // -> true
   plist_is(["size", 5, 10, 4]);           // -> false
   ```
*/
function plist_is(value) =
  is_list(value)
  && (len(value) == 0 || (len(value) % 2 == 0
                          && len([for (i = [0:len(value) - 1])
                                     if (i % 2 == 0
                                         && !is_string(value[i]))
                                       1]) == 0));

/**
   ─────────────────────────────────────────────────────────────────────────────
   plist_get
   ─────────────────────────────────────────────────────────────────────────────

   Get the value associated with a key in a property list.

   **Parameters:**

   `key`: String key to find.
   `plist`: Property list to search.
   `default`: Value returned when `key` is absent (default `undef`).

   **Returns:**

   The value following the first matching key, or `default` when the key is not
   present.

   **Examples:**

   ```scad
   p = ["size", [5, 10], "dia", 4];
   plist_get("dia", p);             // -> 4
   plist_get("none", p);            // -> undef
   plist_get("none", p, "default"); // -> "default"
   ```
*/
function plist_get(key, plist, default) =
  plist_has(key, plist)
  ? [for (i = [0:len(plist) - 1]) if (i % 2 == 0 && plist[i] == key)
                                    plist[i + 1]][0]
  : default;

/**
   ─────────────────────────────────────────────────────────────────────────────
   plist_props
   ─────────────────────────────────────────────────────────────────────────────

   Get several property values in the requested key order.

   **Parameters:**

   `keys`: List of string keys to retrieve.
   `plist`: Property list to search.

   **Returns:**

   A list containing the value for each key. Missing keys produce `undef`.

   **Examples:**

   ```scad
   p = ["size", [5, 10], "dia", 4];
   plist_props(["dia", "none", "size"], p);
   // -> [4, undef, [5, 10]]
   ```
*/
function plist_props(keys, plist) =
  [for (k = keys) plist_get(k, plist)];

/**
   ─────────────────────────────────────────────────────────────────────────────
   plist_has
   ─────────────────────────────────────────────────────────────────────────────

   Check whether a property list contains a key.

   **Parameters:**

   `key`: String key to find.
   `plist`: Property list to search.

   **Returns:**

   `true` when `key` occurs in a key position; otherwise `false`.

   **Examples:**

   ```scad
   p = ["size", [5, 10], "dia", 4];
   plist_has("dia", p);  // -> true
   plist_has("none", p); // -> false
   ```
*/
function plist_has(key, plist) =
  true == [for (i = [0:len(plist) - 1]) if (i % 2 == 0 && plist[i] == key)
                                          true][0];

/**
   ─────────────────────────────────────────────────────────────────────────────
   plist_key_idx
   ─────────────────────────────────────────────────────────────────────────────

   Find a key's array index in a property list.

   **Parameters:**

   `key`: String key to find.
   `plist`: Property list to search.

   **Returns:**

   The zero-based array index of the first matching key, or `undef` when the key
   is absent. Key indices are therefore `0`, `2`, `4`, and so on.

   **Examples:**

   ```scad
   p = ["size", [5, 10], "dia", 4];
   plist_key_idx("size", p); // -> 0
   plist_key_idx("dia", p);  // -> 2
   plist_key_idx("none", p); // -> undef
   ```
*/
function plist_key_idx(key, plist) =
  [for (i = [0:len(plist) - 1]) if (i % 2 == 0 && plist[i] == key)
                                  i][0];

/**
   ─────────────────────────────────────────────────────────────────────────────
   plist_put
   ─────────────────────────────────────────────────────────────────────────────

   Set a property-list value, appending the pair when the key is absent.

   **Parameters:**

   `key`: String key to add or update.
   `value`: Value to associate with `key`.
   `plist`: Source property list.

   **Returns:**

   A new property list. If `key` exists, the value after its first occurrence is
   replaced in place. Otherwise, `[key, value]` is appended.

   **Examples:**

   ```scad
   plist_put("none", 3, ["size", [5, 10], "dia", 4]);
   // -> ["size", [5, 10], "dia", 4, "none", 3]

   plist_put("dia", 3.5, ["dia", 4, "size", [5, 10]]);
   // -> ["dia", 3.5, "size", [5, 10]]
   ```
*/
function plist_put(key, value, plist) =
  let (idx = plist_key_idx(key, plist),
       arr = is_undef(idx)
       ? concat(plist, [key, value])
       : concat(take(plist, idx + 1),
                [value],
                drop(plist, idx + 2)))
  arr
  ;

/**
   ─────────────────────────────────────────────────────────────────────────────
   plist_keys
   ─────────────────────────────────────────────────────────────────────────────

   List the keys in a property list.

   **Parameters:**

   `plist`: Property list whose keys should be returned.

   **Returns:**

   A list of the even-indexed key strings in their original order.

   **Examples:**

   ```scad
   plist_keys(["size", [5, 10], "dia", 4]); // -> ["size", "dia"]
   plist_keys([]);                            // -> []
   ```
*/
function plist_keys(plist) =
  [for (i = [0:len(plist) - 1]) if (i % 2 == 0) plist[i]];

/**
   ─────────────────────────────────────────────────────────────────────────────
   plist_remove
   ─────────────────────────────────────────────────────────────────────────────

   Remove the first pair with a matching key from a property list.

   **Parameters:**

   `key`: String key to remove.
   `plist`: Source property list.

   **Returns:**

   A new property list without the first matching key-value pair. If `key` is
   absent, the original property list is returned.

   **Examples:**

   ```scad
   plist_remove("dia", ["dia", 4, "size", [5, 10]]);
   // -> ["size", [5, 10]]

   plist_remove("none", ["dia", 4, "size", [5, 10]]);
   // -> ["dia", 4, "size", [5, 10]]
   ```
*/
function plist_remove(key, plist) =
  let (idx = plist_key_idx(key, plist),
       arr = is_undef(idx)
       ? plist
       : concat(take(plist, idx),
                drop(plist, idx + 2)))
  arr;

/**
   ─────────────────────────────────────────────────────────────────────────────
   plist_remove_by_keys
   ─────────────────────────────────────────────────────────────────────────────

   Remove every pair matching one key or any key in a list.

   **Parameters:**

   `key_or_keys`: One string key or a list of string keys to remove.
   `plist`: Source property list.

   **Returns:**

   A new property list without pairs whose keys occur in `key_or_keys`. The
   relative order of retained pairs is preserved.

   **Examples:**

   ```scad
   p = ["dia", 4, "size", [5, 10], "color", "red"];
   plist_remove_by_keys("dia", p);
   // -> ["size", [5, 10], "color", "red"]

   plist_remove_by_keys(["dia", "color"], p);
   // -> ["size", [5, 10]]
   ```
*/
function plist_remove_by_keys(key_or_keys, plist) =
  let (keys = is_list(key_or_keys) ? key_or_keys : [key_or_keys])
  flatten_pairs([for (i = [0:2:len(plist)-1])
                    if (!member(plist[i], keys))
                      [plist[i], plist[i + 1]]]);

/**
   ─────────────────────────────────────────────────────────────────────────────
   plist_merge
   ─────────────────────────────────────────────────────────────────────────────

   Merge two property lists, giving the second list precedence.

   **Parameters:**

   `plist_a`: Base property list.
   `plist_b`: Property list containing overrides and additional pairs.

   **Returns:**

   A property list that retains the key order from `plist_a`, substitutes values
   from `plist_b` for matching keys, and appends keys unique to `plist_b` in their
   original order.

   **Examples:**

   ```scad
   plist_merge(["a", 1, "b", 2], ["b", 20, "c", 30]);
   // -> ["a", 1, "b", 20, "c", 30]

   plist_merge(["dia", 4, "size", [5, 10]], ["dia", 3.5]);
   // -> ["dia", 3.5, "size", [5, 10]]
   ```
*/
function plist_merge(plist_a, plist_b) =
  let (keys_a = plist_keys(plist_a),
       keys_b = plist_keys(plist_b),

       part_a = flatten_pairs([for (k = keys_a)
                                  [k, plist_get(k, plist_b, plist_get(k, plist_a))]]),

       part_b = flatten_pairs([for (k = keys_b)
                                  if (!member(k, keys_a))
                                    [k, plist_get(k, plist_b)]]))
  concat(part_a, part_b);

/**
   ─────────────────────────────────────────────────────────────────────────────
   plist_maybe_from_percent
   ─────────────────────────────────────────────────────────────────────────────

   Get a property and convert string percentages to an absolute length.

   String values are parsed by `parse_percent()` and evaluated against `total`.
   The trailing percent sign is optional. Non-string values are returned
   unchanged. The same rules apply to `default` when the property is absent.

   **Parameters:**

   `prop`: String key to retrieve.
   `plist`: Property list to search.
   `default`: Value used when `prop` is absent.
   `total`: Total length in millimeters that represents `100` percent.

   **Returns:**

   The converted length in millimeters for a string value, or the original
   non-string value.

   **Examples:**

   ```scad
   p = ["width", "25%", "height", 12];
   plist_maybe_from_percent("width", p, 0, 200);       // -> 50
   plist_maybe_from_percent("height", p, 0, 200);      // -> 12
   plist_maybe_from_percent("depth", p, "10%", 200);   // -> 20
   ```
*/
function plist_maybe_from_percent(prop, plist, default, total) =
  let (val = plist_get(prop, plist, default),
       num = is_string(val)
       ? percent_to_mm(percent=parse_percent(val),
                       total=total)
       : val)
  num;
