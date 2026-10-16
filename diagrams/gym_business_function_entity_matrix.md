# Gym Database — Business Function–Data Entity Matrix

X = business activity or report uses data from the table. This is not a full CRUD matrix.

| Business function | Members | Plans | Memberships | Payments | Trainers | Class types | Sessions | Enrollments |
|---|---|---|---|---|---|---|---|---|
| Member registration | X | — | — | — | — | — | — | — |
| Plan and pricing management | — | X | — | — | — | — | — | — |
| Membership signup and renewal | X | X | X | — | — | — | — | — |
| Payment collection | — | — | X | X | — | — | — | — |
| Class scheduling | — | — | — | — | X | X | X | — |
| Class reservations and cancellations | X | — | X | — | — | X | X | X |
| Attendance recording | X | — | — | — | — | — | X | X |
| Monthly revenue by membership plan | — | X | X | X | — | — | — | — |
| 30-day membership renewal rate | — | X | X | — | — | — | — | — |
| Class booking utilization | — | — | — | — | — | X | X | X |
| Attendance and no-show rates | — | — | — | — | — | X | X | X |
| Trainer teaching workload | — | — | — | — | X | — | X | — |

The entity columns represent planned tables, not necessarily tables created in the local MySQL database yet.
