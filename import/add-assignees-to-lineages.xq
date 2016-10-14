xquery version "3.1";

let $assigned-territories := doc('/db/apps/gsh/data/assignments.xml')//territory-id
for $lineage in doc('/db/apps/gsh/data/lineages.xml')//lineage[not(review) or review/status="unassigned"]
let $assignee := $assigned-territories[. = $lineage/current-territory/territory-id]/ancestor::assignment/reviewer
let $status := if ($assignee) then "unreviewed" else "unassigned"
let $review-node := 
    element review {
        element status { $status },
        element reviewer { $assignee/string() },
        element reviewed-date { () }
    }
return 
    if (not($lineage/review)) then
        update insert $review-node preceding $lineage/current-territory
    else 
        update replace $lineage/review with $review-node
(: $review-node:)