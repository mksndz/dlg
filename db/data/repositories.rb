# Sample Repositories for development and testing
Repository.create!([
                     { id: 1, slug: 'gaarchives', portal_ids: [1, 3], public: true, title: 'Georgia Archives', notes: 'The Georgia Archives identifies and preserves Georgia\'s most valuable historical documents.'},
                     { id: 2, slug: 'dlg', portal_ids: [1, 2, 3], public: true, title: 'Digital Library of Georgia', notes: 'The Digital Library of Georgia is a gateway to Georgia\'s history and culture found in digitized books, manuscripts, photographs, newspapers, audio, video, and other materials.'},
                     { id: 3, slug: 'tws', portal_ids: [3], public: true, title: 'Rhodes College', homepage_url: 'http://www.rhodes.edu', directions_url: nil, notes: 'Liberal arts college located in Memphis, Tennessee.'},
                     { id: 4, slug: 'msu', portal_ids: [4], public: true, title: 'Mississippi State University. Libraries', notes: nil}
])