$(document).ready ->
  string_fields = {
    "Item ID": "id",
    "Title": "title",
    "Description": "description",
    "Origination date free form": "originated_on_narrative",
    "URL": "url",
    "Language as given": "language",
    "Dialect": "dialect",
    "Region / village": "region",
    "Filename": "filename",
    "Mime Type": "mimetype",
    "FPS": "framesPerSecond",
    "Sample Rate": "samplerate",
    "Channels": "channels",
    "Original media": "original_media",
    "Ingest notes": "ingest_notes",
    "Tracking": "tracking",
    "Data access details": "access_narrative",
    "Comments": "admin_comment"
  }
  date_fields = {
    "Origination date": "originated_on",
    "Date received": "received_on",
    "Date digitised": "digitised_on",
    "Metadata imported": "metadata_imported_on",
    "Metadata exported": "metadata_exported_on",
    "Record created": "created_at",
    "Record modified": "updated_at"
  }
  boolean_fields = {
    "Private": "private",
    "Item not held by Paradisec": "external",
    "Ready for metadata export": "metadata_exportable",
    "Born digital": "born_digital",
    "Tapes returned to depositor": "tapes_returned"
  }
  lookup_fields = {
    "Countries": {field: 'country_ids', source: 'countries_path', multiple: true, type: 'Countries'},
    "Subject languages": {field: 'subject_language_ids', source: 'languages_path', multiple: true, type: 'Languages'},
    "Content languages": {field: 'content_language_ids', source: 'languages_path', multiple: true, type: 'Languages'},
    "Data Categories": {field: 'data_category_ids', source: 'data_categories_path', multiple: true, type: 'Data Category'},
    "Collector": {field: 'collector_id', source: 'users_path', type: 'User'},
    "Operator": {field: 'operator_id', source: 'users_path', type: 'User'},
    "Edit access": {field: 'admin_ids', source: 'users_path', type: 'User', multiple: true},
    "Read/Download access": {field: 'user_ids', source: 'users_path', type: 'User', multiple: true},

    "Originating university": {source: 'universities', static: true},
    "Discourse Type": {field: 'discourse_ids', source: 'discourse_types', static: true},
    "Access Conditions": {field: 'access_condition_id', source: 'access_conditions', static: true}
  }

  filter_groups = []

  # add the simple text search fields
  filter_groups.push {
    filter_group_label: "Text fields",
    filters: _.map(string_fields, (el, key)->
      return {
        filterName: key,
        filterType: "text",
        field: el,
        filterLabel: key,
        excluded_operators: ["in", "not_in"]
      }
    )
  }

  # add the simple boolean search fields - use a select for consistency
  filter_groups.push {
    filter_group_label: "Boolean fields",
    filters: _.map(boolean_fields, (el, key)->
      return {
        filterName: key,
        filterType: "text",
        field: el,
        filterLabel: key,
        excluded_operators: ["in", "not_in", "begins_with", "not_begins_with", "contains", "not_contains", "ends_with",
                             "not_ends_with", "is_empty", "is_not_empty"]
        filter_interface: [
          {
            filter_element: "select"
            filter_element_attributes: {
              class: "filter_list"
            }
          }
        ],
        lookup_values: [
          {lk_option: "True", lk_value: "true"},
          {lk_option: "False", lk_value: "false"}
        ]
      }
    )
  }

  # add the simple date search fields - uses jquery-ui datepicker
  filter_groups.push {
    filter_group_label: "Date fields",
    filters: _.map(date_fields, (el, key)->
      return {
        filterName: key, filterType: "date", field: el, filterLabel: key,
        excluded_operators: ["in", "not_in"],
        filter_interface: [
          {
            filter_element: "input",
            filter_element_attributes: {
              type: "text"
            },
            filter_widget: "datepicker",
            filter_widget_properties: {
              dateFormat: "dd/mm/yy",
              changeMonth: true,
              changeYear: true
            }
          }
        ]
      }
    )
  }

  # add the complex select2 ajax lookup fields
  filter_groups.push {
    filter_group_label: "Lookup fields",
    filters: _.map(lookup_fields, (el, key)->
      filter = {
        filterName: key, filterType: "text", field: el.field, filterLabel: key,
        excluded_operators: excluded_ops,
        filter_interface: []
      }

      excluded_ops = `(_.has(el, 'multiple') && el.multiple) ? [] : ["in", "not_in"]`
      lookup_source = $('meta[name="'+el.source+'"]').attr('content')

      # if static datasource (passed through from rails), just create a select
      if _.has(el, 'static') && el.static
        lookup_values = _.map(JSON.parse(lookup_source), (val)->
          return {lk_option: val[0], lk_value: val[1]}
        )
        filter.filter_interface.push {
          filter_element: "select",
          filter_element_attributes: {
            class: "filter_list"
          }
        }
        filter.lookup_values = lookup_values
      else
        # if dynamic data source, create a select2 with the relevant source url
        filter.filter_interface.push {
          filter_element: "input",
          filter_element_attributes: {
            type: "text"
            class: 'select2',
            'data-url': lookup_source,
            'data-placeholder': 'Select '+`(el.multiple ? '' : ' a ')`+el.type+'...',
            'data-multiple': (_.has(el, 'multiple') && el.multiple)
          }
        }

        # added in this post-create callback to allow the use of arbitrary jquery plugins
        filter.post_create_callback = (el)->
          setup_select2(el.find('.select2'))

      return filter
    )
  }

  # and then apply them all into the filters
  $('#jui_filters').jui_filter_rules {
    filterGroups: filter_groups
  }

  $('input[type="submit"]').on 'click', ()->
    rules = $('#jui_filters').jui_filter_rules('getRules', 0, [])
    $('#hidden_rules').val(JSON.stringify(rules))