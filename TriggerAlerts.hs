module AlertTriggers where

import Protolude

-- A type to represent a field in some object.  Initially, it will be assumed to
-- be a note field but we should be able to expand this to include other
-- objects.
--
-- The type variable represent the type of data in the field.
data Field a

-- Experimenting with a data type for alert trigger definitions
data AlertTrigger a

  -- Triggers whenever a value changes from a previous value.
  = ValueChanged
    (Field a)        -- ^The field to compare to a previous iteration.

  -- For when a value changes with respect to another given value.
  | Threshold
    (Field a)        -- ^Field in question
    a                -- ^Threshold value
    (a -> a -> Bool) -- ^function used to compare field value to threshold

  -- Trigger a notification some number of days (maybe zero) before some date.
  | DueDate
    UTCTime          -- ^The due date
    Natural          -- ^Number of days before due date to send notification

-- This would be the top-level alert definition.
data Alert = Alert
  { alertTrigger :: AlertTrigger
  , alertSubscribers :: AlertSubscribers
  }

data Email

data AlertSubscribers = AlertSubscribers
  { users :: [Email]
  , teams :: [Email]
  , groups :: [Email]
  , externalEmails :: [Email]
  }
