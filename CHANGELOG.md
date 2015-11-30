# 0.1.2 / 2015-11-30

  * Fix bug causing html processor being registered too late, thus not mixing in
    the fingerprinted asset names into the html
  * Fingerprint contents after all assets are fingerprinted, not before
  * Add option to not fingerprint assets
  * Add Vary and Last-Modified cache headers
  * Handle unknown asset types by copying them over during compilation

# 0.1.1 / 2015-11-29

  * Take dependent assets into account when building the hash
  * Use sass gem rather than sassc; choosing reliability over speed
  * Make sure assets middleware executes first

# 0.1.0 / 2015-11-26

 * Initial gem release
