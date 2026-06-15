locals {
  # Build top-level folders map: display_name -> parent org
  top_level = {
    for name, cfg in var.top_level_folders : name => {
      display_name = name
      parent       = "organizations/${var.org_id}"
      code         = cfg.code
      has_bu_subs  = cfg.has_bu_subs
    }
  }

  # Flatten business-unit sub-folders: only under folders with has_bu_subs=true
  bu_pairs = flatten([
    for fname, fcfg in var.top_level_folders : [
      for bu in var.business_units : {
        key          = "${fname}/${bu}"
        display_name = bu
        parent_key   = fname
      }
    ]
    if fcfg.has_bu_subs
  ])

  bu_subfolders = {
    for pair in local.bu_pairs : pair.key => pair
  }

  # Static sub-folders (networking, infrastructure, cicd)
  static_subfolders = {
    for k, v in var.shared_subfolders : k => {
      display_name = v
      parent_key   = split("/", k)[0]
    }
  }
}

# ─── Top-level folders (direct children of the org) ─────────────────────────
resource "google_folder" "top_level" {
  for_each = local.top_level

  display_name = each.value.display_name
  parent       = each.value.parent
}

# ─── Business-unit sub-folders ───────────────────────────────────────────────
resource "google_folder" "business_unit" {
  for_each = local.bu_subfolders

  display_name = each.value.display_name
  parent       = google_folder.top_level[each.value.parent_key].name

  depends_on = [google_folder.top_level]
}

# ─── Static sub-folders (networking, infrastructure, cicd …) ─────────────────
resource "google_folder" "static_sub" {
  for_each = local.static_subfolders

  display_name = each.value.display_name
  parent       = google_folder.top_level[each.value.parent_key].name

  depends_on = [google_folder.top_level]
}
