#
# Default Roles for app
#
Role.delete_all
Role.create!([
                 { name: 'admin' },
                 { name: 'coordinator' },
                 { name: 'supervisor' },
                 { name: 'basic' }
             ])