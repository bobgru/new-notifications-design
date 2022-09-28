# Notes on Design and Implementation of a New Alerts / Notifications System

There is a Jira ticket for an epic that lays out the high-level requirements for
this work.  See it [here](https://jira.verityrms.com/browse/RMS-3032).  That
ticket describes requirements for different types of alerts for note templates
and dashboards.  Within each of those categories different alert triggers are
described.

This work will be done in stages starting with the simplest: alerts sent in
response to *any* changes in note template fields (custom fields).

## Design

### Database

Initial discussions on this concluded that we should be able to leverage the
existing `note_notifications` table in the database:

| Field             | Type     | Notes                                                                                                           |
|:------------------|:---------|-----------------------------------------------------------------------------------------------------------------|
| id                | int      |                                                                                                                 |
| user_id           | int      |                                                                                                                 |
| notification_type | int      | This is an enum that references a row in `notification_types` (there is not an explicit foreign key reference). |
| note_id           | int      |                                                                                                                 |
| created_at        | datetime |                                                                                                                 |
| updated_at        | datetime |                                                                                                                 |
| comment_id        | int      |                                                                                                                 |
| action_originator | varchar  |                                                                                                                 |
| note_title        | varchar  |                                                                                                                 |
| attachment_id     | int      |                                                                                                                 |
| annotation_id     | varchar  |                                                                                                                 |
| vmf_id            | int      |                                                                                                                 |

Another value can be added to the `notification_types` table for this.  What
should this be called?

### Alert Configuration

We need to design a DSL to allow defining the triggers for the alerts.  An
initial JSON structure has been outlined for this.

```
{
  "alert_type": <type>,
  "field": <field name>
  "condition": {
    "operator": <operator type>
    "reference_value": [ X ]
  }
  "subscribers": {
  "users": []
  "teams": []
  "groups": []
  "external_emails": []
  }
  "alert_type":
    "realtime_note_change" – monitors real time note changes
  | "daily_note_change" – runs once a day
  "field": Notes table custom field name
  "operator":
    "any_change": monitors any change of the field, always resets status to “ready”
  | "equal": fires when the values are equal
  | "less_than": fires when the field value is less than reference_value
  | "greater_than": fires when the field value is greater than reference_value
  | "due_in": fires when a date field gets close to the due date. Requires two parameters: due date and proximity
  | "past_due": fires when the date is past due. Requires two parameters: due date and proximity
  "equal":
    "reference_value":
     Target value used for operator to compare against. In 99% it is a single value, but it can be an array when we are talking about multi select fields.
     TODO Do you mean we need to track if any of the values of a multiselect field has the relationship to the reference field?
     TODO could it be another field?
  "external_emails":
}
```

Questions about the above:

1. `field` is duplicated. Which one do we want?
1. `alert_type` is duplicated. Do we want to incorporate the values defined in
   the second defintion?
1. `condition` and `operator` seem to have overlap.  Should they be merged?

See [this Haskell file](TriggerAlerts.hs) for some data types to encode alert triggers.
