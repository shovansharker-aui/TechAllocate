# TechAllocate

Flutter + Firebase monitoring application.

## Current behavior

### Login
- Employee ID + PIN.
- No admin/technician toggle.
- Android supports both technicians and admins.
- Web is available to admins for monitoring.

### Technician task flow
- Search machines by machine name or equipment ID.
- Maximum 5 realtime suggestions.
- Maintenance types:
  - PM = Preventive
  - BM = Breakdown
  - CL = Calibration
  - AD = Adjustment
- A technician can select multiple helpers before starting a task.
- Helpers do not need the Android app or a PIN.
- Starting a task marks the technician and selected helpers as assigned.
- Completing a task releases the technician and all selected helpers.

### Admin settings
- Add employee.
- Add helper (employee ID + name).
- Machine management.

### Admin monitoring dashboard
- Technician count.
- Busy technician count.
- Helper count.
- Active task count.
- Live activity tiles for active technicians and helpers.
- Each activity tile shows name, machine, equipment ID and PM/BM/CL/AD code.
- The grid is intentionally compact; scrolling is allowed when there are many active people.

## Firestore collections

### users
Technician/admin accounts.

### helpers
Helper records:
- employeeId
- name
- status (`available` / `assigned`)
- currentTaskId
- createdAt

### machines
Machine/equipment records.

### work_orders
Active/completed task records. New task fields include:
- type (`preventive`, `breakdown`, `calibration`, `adjustment`)
- machineId
- assignedTechnicianIds
- helperIds
- status
- createdAt
- startedAt
- completedAt
