use <functions.scad>

/**
   Check whether the provided value looks like a property list
   (an even-length array alternating between string keys and values).
*/
function plist_is(value) =
  is_list(value)
  && (len(value) == 0 || (len(value) % 2 == 0
                          && len([for (i = [0:len(value) - 1])
                                     if (i % 2 == 0
                                         && !is_string(value[i]))
                                       1]) == 0));

/**
   ```scad
   my_plist = ["size", [5, 10], "dia", 4];
   plist_get("dia", my_plist) // -> 4
   plist_get("none", my_plist) // -> undef
   plist_get("none", my_plist, "default") // -> "default"
   ```
*/

function plist_get(key, plist, default) =
  plist_has(key, plist)
  ? [for (i = [0:len(plist) - 1]) if (i % 2 == 0 && plist[i] == key)
                                    plist[i + 1]][0]
  : default;

/**
   ```scad
   my_plist = ["size", [5, 10], "dia", 4];
   plist_props(["dia", "none"], my_plist) // -> [4, undef]
   ```
*/
function plist_props(keys, plist) =
  [for (k = keys) plist_get(k, plist)];

/**
   ```scad

   plist_has("dia", ["size", [5, 10], "dia", 4]) // -> true
   plist_has("none", ["size", [5, 10], "dia", 4]) // -> false
   ```
*/
function plist_has(key, plist) =
  true == [for (i = [0:len(plist) - 1]) if (i % 2 == 0 && plist[i] == key)
                                          true][0];

/**
   ```scad

   plist_key_idx("dia", ["size", [5, 10], "dia", 4]) // -> 1
   plist_key_idx("size", ["size", [5, 10], "dia", 4]) // -> 0
   plist_key_idx("none", ["size", [5, 10], "dia", 4]) // -> undef

   ```
*/
function plist_key_idx(key, plist) =
  [for (i = [0:len(plist) - 1]) if (i % 2 == 0 && plist[i] == key)
                                  i][0];

/**
   ```scad
   plist_put("none", 3, ["size", [5, 10], "dia", 4]); // -> ["size", [5, 10], "dia", 4, "none", 3]
   plist_put("dia", 3.5, ["dia", 4, "size", [5, 10]]); // -> ["dia", 3.5, "size", [5, 10]]
   plist_put("dia", 3, []); // -> ["dia", 3]
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
   ```scad
   plist_keys(["size", [5, 10], "dia", 4]); // -> ["size", "dia"]
   ```
*/
function plist_keys(plist) =
  [for (i = [0:len(plist) - 1]) if (i % 2 == 0) plist[i]];

/**
   ```scad
   plist_remove("dia", ["dia", 4, "size", [5, 10]]); // -> ["size", [5, 10]]
   plist_remove("none", ["dia", 4, "size", [5, 10]]); // -> ["dia", 4, "size", [5, 10]]
   ```
*/
function plist_remove(key, plist) =
  let (idx = plist_key_idx(key, plist),
       arr = is_undef(idx)
       ? plist
       : concat(take(plist, idx),
                drop(plist, idx + 2)))
  arr;

// --------------------
// plist_remove_by_keys
// --------------------
/**
   Remove one key or many keys from a property list [k0,v0,k1,v1,...].

   Examples:
   plist_remove_by_keys("dia", ["dia",4,"size",[5,10]]) -> ["size",[5,10]]
   plist_remove_by_keys(["dia","none"], ["dia",4,"size",[5,10]]) -> ["size",[5,10]]
*/
function plist_remove_by_keys(key_or_keys, plist) =
  let (keys = is_list(key_or_keys) ? key_or_keys : [key_or_keys])
  flatten_pairs([for (i = [0:2:len(plist)-1])
                    if (!member(plist[i], keys))
                      [plist[i], plist[i + 1]]]);
/**
   Merge two plists; values from plist_b override plist_a on key conflicts.
   Order: keeps keys from plist_a first (possibly overridden), then adds keys
   that exist only in plist_b (in plist_b order).
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
