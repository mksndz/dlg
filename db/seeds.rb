# Truncate Tables
[
    Subject,
    BatchItem,
    Item,
    User,
    Role,
    Batch,
    Collection,
    Repository
].each do |m|
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{m.table_name} RESTART IDENTITY CASCADE;")
end

#
# Default Subjects for app
#
Subject.delete_all
Subject.create!([
                 { name: 'The Arts' },
                 { name: 'Business & Industry' },
                 { name: 'Education' },
                 { name: 'Folklife' },
                 { name: 'Government & Politic' },
                 { name: 'Land & Resources' },
                 { name: 'Literature' },
                 { name: 'Media' },
                 { name: 'Peoples & Cultures' },
                 { name: 'Religion' },
                 { name: 'Science & Medicine' },
                 { name: 'Sports & Recreation' },
                 { name: 'Transportation' }
             ])

#
# Default Roles for app
#
Role.delete_all
Role.create!([
                 { name: 'admin' },
                 { name: 'coordinator' },
                 { name: 'committer' },
                 { name: 'basic' }
             ])

admin = User.create!(
                email: 'mak@uga.edu',
                password: 'password'
             )

admin.roles << Role.find_by_name('admin')
admin.save

#
# Some Seed Data for Old-School Testing and Display for Meetings, etc.
#

# 3 Repos
Repository.delete_all
r1 = Repository.create!({
    slug: 'chestatee',
    public: true,
    in_georgia: true,
    title: 'Chestatee Regional Library System, Lumpkin County Branch',
    color: 'F1FBFE',
    homepage_url: 'http://www.chestateelibrary.org',
    short_description: 'Chestatee Regional Library System provides support for lifelong learning; general information and answers to questions; and recreational reading, listening and viewing opportunities according to the interests of the community.',
 })

r2 = Repository.create!({
    slug: 'foxfire',
    public: true,
    in_georgia: true,
    title: 'Foxfire Museum & Heritage Center',
    color: 'F8F3EB',
    homepage_url: 'https://www.foxfire.org/',
    short_description: 'Foxfire (The Foxfire Fund, Inc.) is a not-for-profit, educational and literary organization based in Rabun County, Georgia. Founded in 1966, Foxfire\'s learner-centered, community-based educational approach is advocated through both a regional demonstration site (The Foxfire Museum & Heritage Center) grounded in the Southern Appalachian culture that gave rise to Foxfire, and a national program of teacher training and support (the Foxfire Approach to Teaching and Learning) that promotes a sense of place and appreciation of local people, community, and culture as essential educational tools.',
    address: 'Foxfire Museum<br/>98 Foxfire Lane<br/>Mountain City, GA',
    contact: '706-746-5828<br/>The Foxfire Fund, Inc., PO Box 541, Mountain City, Georgia 30562-0541'
 })
r3 = Repository.create!({
    slug: 'gaarchives',
    public: true,
    in_georgia: true,
    title: 'Georgia Archives',
    color: 'F8F3EB',
    homepage_url: 'http://www.georgiaarchives.org',
    directions_url: 'http://www.georgiaarchives.org/visit/',
    short_description: 'The Georgia Archives identifies and preserves Georgia\'s most valuable historical documents. ',
    address: '5800 Jonesboro Road<br/>Morrow, GA 30260',
    contact: 'Reference Services<br/>678-364-3710<br/>Georgia Archives'
 })

# 5 Collections
Collection.delete_all
c1 = Collection.create!({
    repository_id: r1.id,
    slug: 'dahl',
    remote: false,
    display_title: '"Thar\'s gold in them thar hills": Gold and Gold Mining in Georgia, 1830s-1940s',
    color: 'E0E5E0',
    short_description:  'Selected legal, financial, and promotional documents as well as photographs and picture postcards that represent episodes of renewed interest in gold mining in Lumpkin County during Reconstruction, at the turn of the century, and during the Depression from the <a href="http://purl.galileo.usg.edu/dlgbeta/Institutions/chestatee.html">Chestatee Regional Library System</a>',
    dc_title: [
        '"Thar\'s gold in them thar hills": Gold and gold mining in Georgia, 1830s-1940s'
    ],
    dc_subject: [
        'Boyd, Weir, 1820-1893',
        'Dahlonega (Ga.)--History',
        'Dahlonega Branch Mint',
        'Gold industry--Georgia',
        'Gold mines and mining--Georgia--Lumpkin County',
        'Gold mines and mining--Georgia--Dahlonega',
        'Gold mines and mining--Georgia--Auraria',
        'Mines and mineral resources--Equipment and supplies--Georgia--Dahlonega',
        'Mining leases--Georgia--Lumpkin County',
        'Rider Mine',
        'Findley Mill',
        'Findley Gold Mining Company of Georgia',
        'Lockhart Mine',
        'Yahoola River and Cane Creek Hydraulic Hose Mining Company',
        'Consolidated Mines',
        'Phoenix Gold Mining Company',
        'Dahlonega Consolidated Mining Company',
        'Dahlonega Gold Mining and Milling Company'
    ],
    dc_description: [
        '"Thar\'s Gold in Them Thar Hills": Gold and Gold Mining in Georgia, 1830s-1940s consists of selected legal, financial, and promotional documents as well as photographs and picture postcards that represent episodes of renewed interest in gold mining in Lumpkin County during Reconstruction, at the turn of the century, and during the Depression. Culled from three archival collections at the Lumpkin County Library of the Chestatee Regional Library System, the selected textual materials cover the late 1830s through the early 1940s, but focus primarily on the period between Reconstruction and the turn of the twentieth century. By contrast, the photographs and postcards depict mining methods employed from the 1900s through the 1940s along the Chestatee River, at the Findley Mill, and at the Lockhart Mine. Correspondence to Dahlonega attorney Weir Boyd documents the activities of the Rider Mine (1868-1883), the Yahoola and Cane Creek Hydraulic Mining Company (1868-1883), the Consolidated Mines (1879-1882), and the Phoenix Gold Mining company (1891-1892). In-depth descriptions of mining operations and techniques are found within the prospectuses of the Dahlonega Consolidated Gold Mining Company, the Dahlonega Gold Mining and Milling Company, and the Findley Gold Mining Company of Georgia. In addition, Memoranda of deposit from 1838 to 1905 document the Branch Mints in Dahlonega and Charlotte (N.C.). As these materials focus on the period after the Civil War, there is scant mention of area Native Americans, or the Cherokee Removal ("Trail of Tears"). The site also includes an essay of Georgia gold history, a bibliography, and lists of selected websites and related archival materials.'
    ],
    dc_publisher: [
        '[Athens, Ga.] : Digital Library of Georgia'
    ],
    dc_identifier: [
        'http://www.galileo.usg.edu/express?link=dahl'
    ],
    dc_date: [
        '2004'
    ],
    dc_coverage_temporal: [
        '1830/1949'
    ],
    dc_coverage_spatial: [
        'Dahlonega (Ga.)',
        'Auraria (Ga.)',
        'Lumpkin County (Ga.)',
        'Paulding County (Ga.)',
        'White County (Ga.)'
    ],
    dc_contributor: [
        'Chestatee Regional Library System',
        'Digital Library of Georgia'
    ],
    dc_type: [
        'Accounts',
        'Administrative records',
        'Affidavits',
        'Articles of incorporation',
        'Checks',
        'Correspondence',
        'Decisions',
        'Exchange media',
        'Financial records',
        'Government records',
        'Indentures',
        'Invitations',
        'Judicial records',
        'Legal documents',
        'Legal instruments',
        'Letters (correspondence)',
        'Memorandums',
        'Negotiable instruments',
        'Photographs',
        'Picture postcards',
        'Postcards',
        'Promissory notes',
        'Prospectuses',
        'Receipts (financial records)',
        'Records (documents)',
        'Stock certificates',
        'Texts (document genres)',
        'Visual works'
    ],
    dc_right: [
        'Cite as: [Title of document]. [Series, if applicable]. [Collection]. Chestatee Regional Library System, Lumpkin County Branch, presented in the Digital Library of Georgia'
    ]
})

c2 = Collection.create!({
    repository_id: r2.id,
    slug: 'ffcoll',
    remote: false,
    display_title: 'Foxfire Oral Histories, 2014',
    color: 'EEEEEE',
    short_description:  'Oral history interviews about Appalachian folk traditions and music conducted under the auspices of the Foxfire Fund, Inc.',
    dc_title: [
        'Foxfire oral histories, 2014'
    ],
    dc_creator: [
        'Foxfire Fund, Inc.'
    ],
    dc_description: [
        'Oral history interviews about Appalachian folk traditions and music conducted under the auspices of the Foxfire Fund, Inc. Topics include music, soap making, corn doll making, and carving turkey calls.'
    ],
    dc_identifier: [
        'http://dlg.galileo.usg.edu/CollectionsA-Z/ffcoll_search.html'
    ],
    dc_coverage_temporal: [
        '2014'
    ],
    dc_coverage_spatial: [
        'Rabun County (Ga.)',
        'North Carolina',
        'Georgia'
    ],
    dc_contributor: [
        'Foxfire Museum & Heritage Center'
    ],
    dc_type: [
        'Sound',
        'Oral histories',
        'Sound recordings'
    ]
})

c3 = Collection.create!({
    repository_id: r3.id,
    slug: 'gpower',
    remote: false,
    display_title: 'Georgia Power Photograph Collection',
    color: 'EEEEEE',
    short_description:  'Black-and-white photographs of Georgia businesses taken by the Georgia Power Company from 1930 to 1949',
    dc_title: [
        'Georgia Power Photograph Collection'
    ],
    dc_creator: [

    ],
    dc_subject: [
        'Georgia Power Company--Photographs',
        'Electric lighting--Installation--Georgia--Photographs',
        'Business enterprises--Georgia--Photographs'
    ],
    dc_description: [
        'A part of Georgia Power Company\'s business in the 1930s and 1940s was to provide lighting for businesses. Sometimes, photographs were taken before and after installation to show the dramatic improvement made by the new lighting scheme. Many photographs were published in the company\'s magazine, Bright Spots. This collection of black and white photographs from Georgia Power shows the interiors and exteriors of many businesses in Georgia in the 1930s and 1940s and a few outside the state. Available information includes the type of business establishment; the type of shot (interior or exterior); the name of the business; its street address; and the city in which it was located. Not all photographs include identification. Brackets indicate information supplied from other sources such as Bright Spots, city directories, or Web sites.'
    ],
    dc_publisher: [
        'Morrow, Ga. : Georgia Archives'
    ],
    dc_identifier: [
        'http://cdm.georgiaarchives.org:2011/cdm/landingpage/collection/gpower'
    ],
    dc_date: [
        '2006-10'
    ],
    dc_coverage_temporal: [
        '1930/1949'
    ],
    dc_coverage_spatial: [
        'Georgia'
    ],
    dc_contributor: [
        'Georgia Archives'
    ],
    dc_source: [
        '1979-0071M, Georgia Power Company Collection, Georgia Archives, Morrow, Ga.'
    ],
    dc_type: [
        'Black-and-white photographs',
        'Photographs',
        'Visual works'
    ],
    dc_right: [
        'Usage Note: Users may download the images for personal or educational use--students may include images in reports, for instance, and teachers may use the images in the classroom--if the following credit line is included with the image: Courtesy of the Georgia Archives. Each image has a "Cite as" field in the Document Description. Users can form a complete citation by combining the "Business Name" and "Cite as" fields for the individual image. Copyright and Publication: Publication and other commercial use requires written permission and the payment of a use fee. For further information, contact Steve Engerrand.'
    ]
})

c4 = Collection.create!({
    repository_id: r3.id,
    slug: 'vang',
    remote: false,
    display_title: 'Vanishing Georgia',
    color: 'FEEEB0',
    short_description:  'Historically significant photographs of people, places, and structures from Georgia\'s past from the Vanishing Georgia Collection at the Georgia Archives',
    dc_title: [
        'Georgia Power Photograph Collection'
    ],
    dc_subject: [
        'Georgia--History--19th century--Pictorial works',
        'Georgia--History--20th century--Pictorial works',
        'Georgia--Social life and customs--Pictorial works',
        'City and town life--Georgia--Pictorial works'

    ],
    dc_description: [
        'Vanishing Georgia comprises nearly 18,000 photographs documenting more than 100 years of Georgia history and life. These images cover family and business life, street scenes and architecture, agriculture, school and civic activities, landscapes, and important individuals and events in Georgia history among other topics. Between 1975 and 1996, the Georgia Archives duplicated images held by individuals and organizations across the state in an effort to preserve Georgia\'s historical photographs. The Georgia Archives joins with the Digital Library of Georgia to present the Vanishing Georgia images as a digital resource. The site also contains bibliographies, a list of related links, and information about the Vanishing Georgia photographic project. Digital images of black-and-white photographic negatives of graphic and photographic materials, scanned by JJT, Inc. for the Digital Library of Georgia and Georgia Archives as part of a Georgia HomePLACE initiative in 2002-2003.'
    ],
    dc_publisher: [
        '[Athens, Ga.] : Digital Library of Georgia'
    ],
    dc_identifier: [
        'http://dlg.galileo.usg.edu/vanishinggeorgia/'
    ],
    dc_date: [
        '2003'
    ],
    dc_coverage_temporal: [
        '1800/1994'
    ],
    dc_coverage_spatial: [
        'Appling County (Ga.)',
        'Bacon County (Ga.)',
        'Baker County (Ga.)',
        'Baldwin County (Ga.)',
        'Banks County (Ga.)',
        'Barrow County (Ga.)',
        'Bartow County (Ga.)',
        'Ben Hill County (Ga.)',
        'Berrien County (Ga.)',
        'Bibb County (Ga.)',
        'Bleckley County (Ga.)',
        'Brantley County (Ga.)',
        'Brooks County (Ga.)',
        'Bryan County (Ga.)',
        'Bulloch County (Ga.)',
        'Burke County (Ga.)',
        'Butts County (Ga.)',
        'Calhoun County (Ga.)',
        'Camden County (Ga.)',
        'Candler County (Ga.)',
        'Carroll County (Ga.)',
        'Catoosa County (Ga.)',
        'Charlton County (Ga.)',
        'Chatham County (Ga.)',
        'Chattooga County (Ga.)',
        'Cherokee County (Ga.)',
        'Clarke County (Ga.)',
        'Clay County (Ga.)',
        'Clayton County (Ga.)',
        'Clinch County (Ga.)',
        'Cobb County (Ga.)',
        'Coffee County (Ga.)',
        'Colquitt County (Ga.)',
        'Columbia County (Ga.)',
        'Cook County (Ga.)',
        'Coweta County (Ga.)',
        'Crawford County (Ga.)',
        'Crisp County (Ga.)',
        'Dawson County (Ga.)',
        'Decatur County (Ga.)',
        'Dekalb County (Ga.)',
        'Dodge County (Ga.)',
        'Dooly County (Ga.)',
        'Dougherty County (Ga.)',
        'Douglas County (Ga.)',
        'Early County (Ga.)',
        'Echols County (Ga.)',
        'Effingham County (Ga.)',
        'Elbert County (Ga.)',
        'Emanuel County (Ga.)',
        'Evans County (Ga.)',
        'Fannin County (Ga.)',
        'Fayette County (Ga.)',
        'Floyd County (Ga.)',
        'Forsyth County (Ga.)',
        'Franklin County (Ga.)',
        'Fulton County (Ga.)',
        'Gilmer County (Ga.)',
        'Glascock County (Ga.)',
        'Glynn County (Ga.)',
        'Gordon County (Ga.)',
        'Grady County (Ga.)',
        'Greene County (Ga.)',
        'Gwinnett County (Ga.)',
        'Habersham County (Ga.)',
        'Hall County (Ga.)',
        'Hancock County (Ga.)',
        'Haralson County (Ga.)',
        'Harris County (Ga.)',
        'Hart County (Ga.)',
        'Heard County (Ga.)',
        'Henry County (Ga.)',
        'Houston County (Ga.)',
        'Irwin County (Ga.)',
        'Jackson County (Ga.)',
        'Jasper County (Ga.)',
        'Jeff Davis County (Ga.)',
        'Jefferson County (Ga.)',
        'Jenkins County (Ga.)',
        'Johnson County (Ga.)',
        'Jones County (Ga.)',
        'Lamar County (Ga.)',
        'Lanier County (Ga.)',
        'Laurens County (Ga.)',
        'Lee County (Ga.)',
        'Liberty County (Ga.)',
        'Long County (Ga.)',
        'Lowndes County (Ga.)',
        'Lumpkin County (Ga.)',
        'Macon County (Ga.)',
        'Madison County (Ga.)',
        'Marion County (Ga.)',
        'Mcduffie County (Ga.)',
        'Mcintosh County (Ga.)',
        'Meriwether County (Ga.)',
        'Miller County (Ga.)',
        'Mitchell County (Ga.)',
        'Monroe County (Ga.)',
        'Montgomery County (Ga.)',
        'Morgan County (Ga.)',
        'Murray County (Ga.)',
        'Muscogee County (Ga.)',
        'Newton County (Ga.)',
        'Oconee County (Ga.)',
        'Oglethorpe County (Ga.)',
        'Paulding County (Ga.)',
        'Peach County (Ga.)',
        'Pickens County (Ga.)',
        'Pierce County (Ga.)',
        'Pike County (Ga.)',
        'Polk County (Ga.)',
        'Pulaski County (Ga.)',
        'Putnam County (Ga.)',
        'Quitman County (Ga.)',
        'Rabun County (Ga.)',
        'Randolph County (Ga.)',
        'Richmond County (Ga.)',
        'Rockdale County (Ga.)',
        'Schley County (Ga.)',
        'Screven County (Ga.)',
        'Seminole County (Ga.)',
        'Spalding County (Ga.)',
        'Stephens County (Ga.)',
        'Stewart County (Ga.)',
        'Sumter County (Ga.)',
        'Talbot County (Ga.)',
        'Taliaferro County (Ga.)',
        'Tattnall County (Ga.)',
        'Taylor County (Ga.)',
        'Telfair County (Ga.)',
        'Terrell County (Ga.)',
        'Thomas County (Ga.)',
        'Tift County (Ga.)',
        'Toombs County (Ga.)',
        'Towns County (Ga.)',
        'Troup County (Ga.)',
        'Turner County (Ga.)',
        'Twiggs County (Ga.)',
        'Union County (Ga.)',
        'Upson County (Ga.)',
        'Walker County (Ga.)',
        'Walton County (Ga.)',
        'Ware County (Ga.)',
        'Warren County (Ga.)',
        'Washington County (Ga.)',
        'Webster County (Ga.)',
        'Wheeler County (Ga.)',
        'White County (Ga.)',
        'Whitfield County (Ga.)',
        'Wilcox County (Ga.)',
        'Wilkes County (Ga.)',
        'Wilkinson County (Ga.)',
        'Worth County (Ga.)'
    ],
    dc_contributor: [
        'Georgia Archives'
    ],
    dc_source: [
        'Collection held by: Georgia Department of Archives and History, Morrow, Ga.'
    ],
    dc_relation: [
        'Selected images previously issued as a monograph; Published as Georgia. Dept. of Archives and History, Vanishing Georgia (Athens : University of Georgia Press, c1982).'
    ],
    dc_type: [
        'Black-and-white photographs',
        'Photographs',
        'Visual works'
    ],
    dc_right: [
        'Cite as: [Title of the image], [date of image], [material type, i.e., slide or photograph] by [name of photographer (if given)], Vanishing Georgia Collection, Georgia Division of Archives and History, presented in the Digital Library of Georgia'
    ]
})


c5 = Collection.create!({
    repository_id: r3.id,
    slug: 'postcard',
    remote: false,
    display_title: 'Historic Postcard Collection',
    color: 'EEEEEE',
    short_description:  'Postcards depicting historic buildings and landmarks throughout Georgia from the collections of the Georgia Archives',
    dc_title: [
        'Historic postcard collection'
    ],
    dc_subject: [
        'Historic buildings--Georgia--Pictorial works',
        'Monuments--Georgia--Pictorial works',
        'Georgia--Buildings, structures, etc.--Pictorial works'
    ],
    dc_description: [
        'These 1,666 postcards, dating from the early 1900s through the 1970s, come from a variety of sources in the collections of the Georgia Archives.They depict many historical buildings and landmarks throughout the state.Of particular interest are postcards collected in the 1920s by the Georgia Chapter of the Daughters of the American Revolution historical markers erected in Georgia by the D.A.R.'
    ],
    dc_publisher: [
        'Atlanta, Ga. : Georgia Archives'
    ],
    dc_identifier: [
        'http://cdm.georgiaarchives.org:2011/cdm/landingpage/collection/postcard'
    ],
    dc_date: [
        '2006-02'
    ],
    dc_coverage_temporal: [
        '1900/1977'
    ],
    dc_coverage_spatial: [
        'Georgia'
    ],
    dc_contributor: [
        'Georgia Archives'
    ],
    dc_type: [
        'Picture postcards',
        'Postcards',
        'Visual works'
    ],
    dc_right: [
        'Publication is prohibited. Postcards published after 1923 may be covered by copyright. This collection is provided for reference and educational purposes only. The Georgia Archives cannot provide permission to publish. Users may download the images for personal or educational use--students may include images in reports, for instance, and teachers may use the images in the classroom--if the following credit line is included with the image: Courtesy of the Georgia Archives. Each image has a "Cite as" field in the Document Description. Users can form a complete citation by combining the "Caption" and "Cite as" fields for the individual image.'
    ]
})

# Items

# c1
i1 = Item.create!({
    collection_id: c1.id,
    slug: 'mka064',
    dpla: false,
    public: true,
    dc_title: [
        '1937 - front of Lockhart tunnel, J. R. McDonald'
    ],
    dc_subject: [
        'McDonald, J. R.',
        'Lockhart Mine',
        'Gold mines and mining--Georgia--Dahlonega',
        'Mineral rights--Georgia--Dahlonega',
        'Mining leases--Georgia--Dahlonega',
        'Mine shafts--Georgia--Dahlonega',
    ],
    dc_description: [
        'Photograph of three men posed in front of the entrance to the Lockhart Mine, dated 1937.',
        'Document ID: mka064.', #wtf
        'A project of the Digital Library of Georgia in association with the Lumpkin County Library, Chestatee Regional Library System as part of Georgia HomePLACE. This project is supported with federal LSTA funds administered by the Institute of Museum and Library Services through the Georgia Public Library Service, a unit of the Board of Regents of the University System of Georgia.'
    ],
    dc_publisher: [
        'Athens, Ga. : Digital Library of Georgia'
    ],
    dc_identifier: [
        'http://dlg.galileo.usg.edu/dahl/id:mka064'
    ],
    dc_date: [
        '2004'
    ],
    dc_coverage_temporal: [
        '2004'
    ],
    dc_coverage_spatial: [
    ],
    dc_contributor: [
        'Chestatee Regional Library System, Lumpkin County Branch'
    ],
    dc_source: [
        '1 photograph',
        'Manuscript held by the Chestatee Regional Library System, Lumpkin County Branch, Madeleine K. Anthony Collection, box V-3, folder 4.'
    ],
    dc_format: [
        'image/jpeg'
    ],
    dc_relation: [
    ],
    dc_type: [
        'Photographs',
        'StillImage'
    ],
    dc_right: [
        'This work is the property of the Digital Library of Georgia. It may be used freely by individuals for research, teaching, and personal use as long as this statement of availability is included in the text.',
        'Cite as: [title of item], [title of series, if applicable], Madeleine K. Anthony Collection, Chestatee Regional Library System, Lumpkin County Branch, presented in the Digital Library of Georgia'
    ]
})

i2 = Item.create!({
    collection_id: c1.id,
    slug: 'mka024',
    dpla: false,
    public: true,
    dc_title: [
        'Account of the Hand v. Hungerford, et al. case, Dahlonega, Georgia, 1879 Aug. 14'
    ],
    dc_creator: [
        'Greenleaf, Ed E.'
    ],
    dc_subject: [
        'Actions and defenses--Georgia--Dahlonega',
        'Collecting of accounts--Georgia--Dahlonega',
        'Cincinnati Mining Company',
        'Gold mines and mining--Georgia--Dahlonega'
    ],
    dc_description: [
        'Ledger rendered by Ed E. Greenleaf, dated August 14, 1879. This itemized list of charges appears to have been drawn up for the court case Hand v. Hungerford, et al., in which Nathan H. Hand sues W. S. Hungerford, R. F. Williams, and the Cincinnati Mining Company.',
        'Document ID: mka024.',
        'A project of the Digital Library of Georgia in association with the Lumpkin County Library, Chestatee Regional Library System as part of Georgia HomePLACE. This project is supported with federal LSTA funds administered by the Institute of Museum and Library Services through the Georgia Public Library Service, a unit of the Board of Regents of the University System of Georgia.',
    ],
    dc_publisher: [
        'Athens, Ga. : Digital Library of Georgia'
    ],
    dc_identifier: [
        'http://dlg.galileo.usg.edu/dahl/id:mka024'
    ],
    dc_date: [
        '2004'
    ],
    dc_coverage_temporal: [
        '1879-08-14'
    ],
    dc_coverage_spatial: [
        'Dahlonega (Ga.)',
        'Lumpkin County (Ga.)',
    ],
    dc_contributor: [
        'Chestatee Regional Library System, Lumpkin County Branch'
    ],
    dc_source: [
        '[2] p.',
        'Manuscript held by the Chestatee Regional Library System, Lumpkin County Branch, Madeleine K. Anthony Collection, box II-1, folder 38.'
    ],
    dc_relation: [
    ],
    dc_type: [
        'Lists (document genres)',
        'Text'
    ],
    dc_right: [
        'This work is the property of the Digital Library of Georgia. It may be used freely by individuals for research, teaching, and personal use as long as this statement of availability is included in the text.',
        'Cite as: [title of item], [title of series, if applicable], Madeleine K. Anthony Collection, Chestatee Regional Library System, Lumpkin County Branch, presented in the Digital Library of Georgia'
    ]
})

i3 = Item.create!({
    collection_id: c1.id,
    slug: 'mka046',
    dpla: false,
    public: true,
    dc_title: [
        'Building Findley Mill, "setting stamps," [1938?]'
    ],
    dc_subject: [
        'Gold mines and mining--Georgia--Dahlonega',
        'Building--Georgia--Dahlonega',
        'Mining machinery--Georgia--Dahlonega',
        'Hydraulic mining--Georgia--Dahlonega',
        'Findley Mill',
        'Mines and mineral resources--Equipment and supplies--Georgia--Dahlonega',
    ],
    dc_description: [
        'Photograph of Findley Mill construction, featuring the setting of the stamps in 1938.',
        'Document ID: mka046.',
        'A project of the Digital Library of Georgia in association with the Lumpkin County Library, Chestatee Regional Library System as part of Georgia HomePLACE. This project is supported with federal LSTA funds administered by the Institute of Museum and Library Services through the Georgia Public Library Service, a unit of the Board of Regents of the University System of Georgia.'
    ],
    dc_publisher: [
        'Athens, Ga. : Digital Library of Georgia'
    ],
    dc_identifier: [
        'http://dlg.galileo.usg.edu/dahl/id:mka046'
    ],
    dc_date: [
        '2004'
    ],
    dc_coverage_temporal: [
        '1938'
    ],
    dc_coverage_spatial: [
        'Dahlonega (Ga.)',
        'Lumpkin County (Ga.)',
    ],
    dc_format: [
        'image/jpeg'
    ],
    dc_contributor: [
        'Chestatee Regional Library System, Lumpkin County Branch'
    ],
    dc_source: [
        '1 photograph',
        'Manuscript held by the Chestatee Regional Library System, Lumpkin County Branch, Madeleine K. Anthony Collection, box III-8, folder 14.',
    ],
    dc_relation: [
    ],
    dc_type: [
        'Photographs',
        'StillImage',
    ],
    dc_right: [
          'This work is the property of the Digital Library of Georgia. It may be used freely by individuals for research, teaching, and personal use as long as this statement of availability is included in the text.'
    ]
})

i4 = Item.create!({
    collection_id: c1.id,
    slug: 'mka043',
    dpla: false,
    public: true,
    dc_title: [
        'Blank stock certificate for the Etowah Mining Company, [1900-1940?]'
    ],
    dc_creator: [
        'Etowah Mining Company'
    ],
    dc_subject: [
        'Etowah Gold Mining Company',
        'Gold mines and mining--Georgia--Auraria',
        'Mining leases--Georgia--Auraria',
        'Mineral rights--Georgia--Auraria',
        'Capital stock--Georgia--Auraria',
    ],
    dc_description: [
        'Blank stock certificate of the Etowah Mining Company.',
        'Document ID: mka043.',
        'A project of the Digital Library of Georgia in association with the Lumpkin County Library, Chestatee Regional Library System as part of Georgia HomePLACE. This project is supported with federal LSTA funds administered by the Institute of Museum and Library Services through the Georgia Public Library Service, a unit of the Board of Regents of the University System of Georgia.'
    ],
    dc_publisher: [
        'Athens, Ga. : Digital Library of Georgia'
    ],
    dc_identifier: [
        'http://dlg.galileo.usg.edu/dahl/id:mka043'
    ],
    dc_date: [
        '2004'
    ],
    dc_coverage_temporal: [
        '1900/1940'
    ],
    dc_coverage_spatial: [
        'Auraria (Ga.)',
        'Lumpkin County (Ga.)',
    ],
    dc_contributor: [
        'Chestatee Regional Library System, Lumpkin County Branch'
    ],
    dc_source: [
        '[2] p.',
        'Manuscript held by the Chestatee Regional Library System, Lumpkin County Branch, Madeleine K. Anthony Collection, box III-8, folder 11.'
    ],
    dc_format: [
        'image/jpeg'
    ],
    dc_relation: [
    ],
    dc_type: [
        'Stock certificates',
        'Text',
    ],
    dc_right: [
        'This work is the property of the Digital Library of Georgia. It may be used freely by individuals for research, teaching, and personal use as long as this statement of availability is included in the text.',
        'Cite as: [title of item], [title of series, if applicable], Madeleine K. Anthony Collection, Chestatee Regional Library System, Lumpkin County Branch, presented in the Digital Library of Georgia'

    ]
})

# c2
i5 = Item.create!({
    collection_id: c2.id,
    slug: 'beanie-ramey',
    dpla: true,
    public: true,
    dc_title: [
        'Oral history interview with Beanie Ramey, 2014'
    ],
    dc_subject: [
        'Cherokee Indians',
        'Crawford family',
        'Motels--Georgia--Rabun County',
        'Motion picture locations--Georgia--Rabun County',
        'Parker, Fess',
        'Four seasons (Motion picture : 1981)',
        'Wagon trains',
        'Piano Red, 1911-1985',
        'Nightclubs--Georgia--Clayton',
        'African Americans--Georgia--Rabun County',
        'Fires--Georgia--Tiger',
        'Real property--Georgia--Rabun County',
        'Rabun County (Ga.)--Race relations',
        'Mayors--Georgia--Rabun County',
    ],
    dc_creator: [
        'Blackwell, Curtis'
    ],
    dc_description: [
        'Interview with Beanie Ramey of Rabun County, Georgia, c. 2014, for Foxfire magazine. She discusses her family history, Cherokee heritage, and growing up in Tiger, Georgia. She talks about her parents, M. L. and Eva Crawford, and how they used to raise and sell dogs. Ramey recalls working at the historic Bynum House (Clayton, Ga.) and running a gas station and motel with her husband. She talks about the filming of the 1956 Disney movie, The Great Locomotive Chase, and other films in Rabun County, and meeting some of the film stars. She was also Carol Burnett\'s stand-in in the film Four Seasons. She discusses going on wagon trains and travelling the country in her motor home. She talks about the Clayton Club and musician Piano Red, the burning of the looper factory in Tiger, and how the towns of Tiger and Clayton have changed over the years. She also discusses race relations in Rabun County and talks about her husband, Tom Ramey, a former mayor of Rabun County. This interview appeared in Foxfire\'s Fall/Winter 2014 issue.'
    ],
    dc_publisher: [
    ],
    dc_identifier: [
        'http://dlg.galileo.usg.edu/foxfire/do-mp3:beanie-ramey'
    ],
    dc_date: [
    ],
    dc_coverage_temporal: [
        '2014'
    ],
    dc_coverage_spatial: [
        'Tiger (Ga.)',
        'Clayton (Ga.)',
        'Rabun County (Ga.)',
    ],
    dc_contributor: [
    ],
    dc_format: [
        'audio/mp3',
        '1 interview (circa 126 mins.)'
    ],
    dc_source: [
    ],
    dc_relation: [
    ],
    dc_type: [
        'Sound',
        'Oral histories',
    ],
    dc_right: [
        '&copy; Foxfire Fund, Inc.',
        'Cite as:  [item identification], [collection name], Foxfire Museum  Heritage Center, Mountain City, Georgia.',
        'This material is protected by copyright law. (Title 17, U.S Code) Permission for use must be cleared through The Foxfire Fund, Inc. Licensing agreement may be required.',
        'Athens, Ga. : Digital Library of Georgia in association with the Foxfire Fund, Inc.',
        '2015',
        'Foxfire Fund',
    ]
})

i6 = Item.create!({
    collection_id: c2.id,
    slug: 'curtis-blackwell',
    dpla: true,
    public: true,
    dc_title: [
        'Oral history interview with Curtis Blackwell, 2014'
    ],
    dc_subject: [
        'Bluegrass music--North Carolina',
        'Bluegrass musicians--North Carolina--Macon County',
        'Dixie Bluegrass Boys (Musical group : Randall Collins)',
        'Guitarists--North Carolina--Macon County',
    ],
    dc_creator: [
        'Blackwell, Curtis'
    ],
    dc_description: [
        'Blues musician and member of the Dixie Bluegrass Boys, born September 13, 1942',
        'Interviewed by  in Macon County (N.C.), 2014',
        'Interview with bluegrass musician Curtis Blackwell, Macon Couty, North Carolina, c. 2014, for Foxfire magazine. He talks about learning to play guitar and playing with the Dixie Bluegrass Boys. He also discusses his musical style and influences.'
    ],
    dc_publisher: [
    ],
    dc_identifier: [
        'http://dlg.galileo.usg.edu/foxfire/do-mp3:curtis-blackwell'
    ],
    dc_date: [
    ],
    dc_coverage_temporal: [
        '2014'
    ],
    dc_coverage_spatial: [
        'Macon County (N.C.)'
    ],
    dc_contributor: [
    ],
    dc_format: [
        'audio/mp3',
        '1 interview (circa 28 mins.)',
    ],
    dc_source: [
    ],
    dc_relation: [
    ],
    dc_type: [
        'Sound',
        'Oral histories',
    ],
    dc_right: [
        '&copy; Foxfire Fund, Inc.',
        'Cite as:  [item identification], [collection name], Foxfire Museum  Heritage Center, Mountain City, Georgia.',
        'This material is protected by copyright law. (Title 17, U.S Code) Permission for use must be cleared through The Foxfire Fund, Inc. Licensing agreement may be required.',
        'Athens, Ga. : Digital Library of Georgia in association with the Foxfire Fund, Inc.',
        '2015',
        'Foxfire Fund',
    ]
})

i7 = Item.create!({
    collection_id: c2.id,
    slug: 'dale-holland-audio',
    dpla: true,
    public: true,
    dc_title: [
        'Oral history interview with Dale Holland, 2014 June 18'
    ],
    dc_subject: [
        'Turkey hunting--North Carolina',
        'Turkey calls--North Carolina',
        'Wood-carving--North Carolina',
    ],
    dc_creator: [
        'Holland, Dale',
        'Finley, Breanna',
        'Lunsford, Ross',
        'Blackstock, Jon',
    ],
    dc_description: [
        'North Carolina turkey call maker',
        'Interviewed by Breanna Finley, Ross Lunsford, Jon Blackstock, and Corey Lovell in Macon County (N.C.), 2014 June 18',
    ],
    dc_publisher: [
    ],
    dc_identifier: [
        'http://dlg.galileo.usg.edu/foxfire/do-mp3:dale-holland-audio'
    ],
    dc_date: [
    ],
    dc_coverage_temporal: [
        '2014-06-18'
    ],
    dc_coverage_spatial: [
        'Macon County (N.C.)'
    ],
    dc_contributor: [
    ],
    dc_format: [
        'audio/mp3',
        '1 interview (circa 118 mins.)',
    ],
    dc_source: [
    ],
    dc_relation: [
    ],
    dc_type: [
        'Sound',
        'Oral histories',
    ],
    dc_right: [
        '&copy; Foxfire Fund, Inc.',
        'Cite as:  [item identification], [collection name], Foxfire Museum  Heritage Center, Mountain City, Georgia.',
        'This material is protected by copyright law. (Title 17, U.S Code) Permission for use must be cleared through The Foxfire Fund, Inc. Licensing agreement may be required.',
        'Athens, Ga. : Digital Library of Georgia in association with the Foxfire Fund, Inc.',
        '2015',
        'Foxfire Fund',
    ]
})

i8 = Item.create!({
    collection_id: c2.id,
    slug: 'john-roper-audio',
    dpla: true,
    public: true,
    dc_title: [
        'Oral history interview with John Roper, 2014 June 19'
    ],
    dc_subject: [
        'Furniture making--North Carolina',
        'Woodwork--North Carolina',
    ],
    dc_creator: [
        'Roper, John',
        'Lunsford, Ross',
        'Finley, Breanna',
        'Lovell, Corey',
    ],
    dc_description: [
        'North Carolina furniture maker',
        'Interviewed by Breanna Finley, Ross Lunsford,  and Corey Lovell in Macon County (N.C.), 2014 June 19',
        'Interview with John Roper, June 19, 2014, in Burningtown, North Carolina, for Foxfire magazine. He talks about making furniture and discusses the equipment and type of wood he uses. At the end, he discusses reading the Foxfire books.',
    ],
    dc_publisher: [
    ],
    dc_identifier: [
        'http://dlg.galileo.usg.edu/foxfire/do-mp3:john-roper-audio'
    ],
    dc_date: [
    ],
    dc_coverage_temporal: [
        '2014-06-19'
    ],
    dc_coverage_spatial: [
        'North Carolina'
    ],
    dc_contributor: [
    ],
    dc_format: [
        'audio/mp3',
        '1 interview (circa 63 mins.)',
    ],
    dc_source: [
    ],
    dc_relation: [
    ],
    dc_type: [
        'Sound',
        'Oral histories',
    ],
    dc_right: [
        '&copy; Foxfire Fund, Inc.',
        'Cite as:  [item identification], [collection name], Foxfire Museum  Heritage Center, Mountain City, Georgia.',
        'This material is protected by copyright law. (Title 17, U.S Code) Permission for use must be cleared through The Foxfire Fund, Inc. Licensing agreement may be required.',
        'Athens, Ga. : Digital Library of Georgia in association with the Foxfire Fund, Inc.',
        '2015',
        'Foxfire Fund',
    ]
})

# c3 van ga
i9 = Item.create!({
    collection_id: c4.id,
    slug: 'app001',
    dpla: true,
    public: true,
    dc_title: [
        '[Photograph of Claude Mulling on tricycle, Appling County, Georgia, 1922]'
    ],
    dc_subject: [
        'Portraits--Georgia--Appling County',
        'Children--Georgia--Appling County',
        'Tricycles--Georgia--Appling County',
        'Riding toys--Georgia--Appling County',
    ],
    dc_description: [
        '"Appling County, 1922. Claude Mulling on tricycle. An early toy."--from field notes'
    ],
    dc_publisher: [
        '[Athens, Ga. : Digital Library of Georgia]'
    ],
    dc_identifier: [
    'http://dlg.galileo.usg.edu/vang/id:app001'
    ],
    dc_date: [
        '2004'
    ],
    dc_coverage_temporal: [
        '1922'
    ],
    dc_coverage_spatial: [
        'Appling County (Ga.)'
    ],
    dc_format: [
        'image/jpeg',
        'image/x-mrsid',
    ],
    dc_contributor: [
        'Georgia Archives'
    ],
    dc_source: [
    ],
    dc_relation: [
    ],
    dc_type: [
        'Photographs',
        'StillImage',
    ],
    dc_right: [
        'Held by Georgia Archives, 5800 Jonesboro Road, Morrow, GA 30260.',
        'Contact repository re: reproduction and usage.',
    ]
})

i10 = Item.create!({
    collection_id: c4.id,
    slug: 'bak003',
    dpla: true,
    public: true,
    dc_title: [
        'Up to Date Camp, Newton, Ga June 1897'
    ],
    dc_subject: [
        'Camps--Georgia--Newton',
        'Camping--Georgia--Newton',
        'Outdoor recreation--Georgia--Newton',
        'Fishing--Georgia--Newton',
        'Women--Georgia--Newton',
        'Clubs--Georgia--Newton',
        'Costume--Georgia--Newton',
        'Portraits--Georgia--Newton',
        'Recreations--Georgia--Newton',
    ],
    dc_description: [
        'Newton, June 1897. Group of visitors to "Up-to-Date Camp" pose for a photograph. They slept in tents and fished in a nearby river. See: Case File for additional information.'
    ],
    dc_publisher: [
        '[Athens, Ga. : Digital Library of Georgia]'
    ],
    dc_identifier: [
        'http://dlg.galileo.usg.edu/vang/id:app001'
    ],
    dc_date: [
        '2004'
    ],
    dc_coverage_temporal: [
        '1897'
    ],
    dc_coverage_spatial: [
        'Newton (Ga.)',
        'Baker County (Ga.)',
    ],
    dc_format: [
        'image/jpeg',
        'image/x-mrsid',
    ],
    dc_contributor: [
        'Georgia Archives'
    ],
    dc_source: [
    ],
    dc_relation: [
    ],
    dc_type: [
        'Photographs',
        'StillImage',
    ],
    dc_right: [
        'Held by Georgia Archives, 5800 Jonesboro Road, Morrow, GA 30260.',
        'Contact repository re: reproduction and usage.',
    ]
})

i11 = Item.create!({
    collection_id: c4.id,
    slug: 'bak006-82',
    dpla: true,
    public: true,
    dc_title: [
        '[Photograph of Wesley Wiley and dog, Baker County, Georgia, 1940 or 1941]'
    ],
    dc_subject: [
        'Architecture--Georgia--Baker County',
        'Portraits--Georgia--Baker County',
        'Baker County (Ga.)--Religion',
        'Dogs--Georgia--Baker County',
    ],
    dc_description: [
        '"Baker County, 1940-1941. Patmos Free Will Baptist church in background. Wesley Wiley and dog."--from field notes'
    ],
    dc_publisher: [
        '[Athens, Ga. : Digital Library of Georgia]'
    ],
    dc_identifier: [
        'http://dlg.galileo.usg.edu/vang/id:bak006-82'
    ],
    dc_date: [
        '2004'
    ],
    dc_coverage_temporal: [
        '1940/1941'
    ],
    dc_coverage_spatial: [
        'Baker County (Ga.)'
    ],
    dc_format: [
        'image/jpeg',
        'image/x-mrsid',
    ],
    dc_contributor: [
        'Georgia Archives'
    ],
    dc_source: [
    ],
    dc_relation: [
    ],
    dc_type: [
        'Photographs',
        'StillImage',
    ],
    dc_right: [
        'Held by Georgia Archives, 5800 Jonesboro Road, Morrow, GA 30260.',
        'Contact repository re: reproduction and usage.',
    ]
})

i12 = Item.create!({
    collection_id: c4.id,
    slug: 'bak007-82',
    dpla: true,
    public: true,
    dc_title: [
        '[Photograph of Lanier family at home, Baker County, Georgia, ca. 1914]'
    ],
    dc_subject: [
        'Domestic life--Georgia--Baker County',
        'Portraits--Georgia--Baker County',
    ],
    dc_description: [
        '"Baker County, ca. 1914. Left to right: Herman Lanier, Emma Lanier (mother), James Marion Lanier, Robert Reuben Lanier (father), Irene Lanier. Lanier home place. Near Early County line."--from field notes'
    ],
    dc_publisher: [
        '[Athens, Ga. : Digital Library of Georgia]'
    ],
    dc_identifier: [
        'http://dlg.galileo.usg.edu/vang/id:bak007-82'
    ],
    dc_date: [
        '2004'
    ],
    dc_coverage_temporal: [
        '1914'
    ],
    dc_coverage_spatial: [
        'Baker County (Ga.)'
    ],
    dc_format: [
        'image/jpeg',
        'image/x-mrsid',
    ],
    dc_contributor: [
        'Georgia Archives'
    ],
    dc_source: [
    ],
    dc_relation: [
    ],
    dc_type: [
        'Photographs',
        'StillImage',
    ],
    dc_right: [
        'Held by Georgia Archives, 5800 Jonesboro Road, Morrow, GA 30260.',
        'Contact repository re: reproduction and usage.',
    ]
})

# c4 postcards
i13 = Item.create!({
    collection_id: c5.id,
    slug: '867',
    dpla: true,
    public: true,
    dc_title: [
        '$10,000 Monument to be Generals Stewart and Screven.  To be Erected at Midway Liberty County Georgia.  Designed by and Contract Awarded to the McNeel Marble Company, Marietta, Ga.'
    ],
    dc_subject: [
        'Monuments--Georgia--Midway',
        'Marble industry and tade--Georgia',
        'Stewart, Daniel, 1761-1829--Monuments',
        'McNeel Marble Company (Marietta, Ga.)',
    ],
    dc_description: [
        'The largest manufacturers of monuments in the Unite States are the McNeel Marble Company.  No order too small, none too large.  All are given the same careful attention.  Twenty years\' experience and satisfactory dealings behind every shipment.  Write us.  The McNeel Marble Company.  Marble and Granite, Marietta, Ga.'
    ],
    dc_publisher: [
    ],
    dc_identifier: [
        'http://cdm.georgiaarchives.org:2011/cdm/singleitem/collection/postcard/id/867'
    ],
    dc_date: [
    ],
    dc_coverage_temporal: [
    ],
    dc_coverage_spatial: [
        'Midway (Ga.)',
        'Liberty County (Ga.)',
    ],
    dc_contributor: [
        'Georgia Archives'
    ],
    dc_format: [
        'Visual image',
        'image/jpeg',
    ],
    dc_source: [
        'Historic Postcard Collection, RG 48-2-5, Georgia Archives',
        'Postcards published after 1923 may be covered by copyright.  The Georgia Archives cannot provide permission to publish.',
    ],
    dc_relation: [
        'Historic Postcard Collection'
    ],
    dc_type: [
        'StillImage'
    ],
    dc_right: [
    ]
})

i14 = Item.create!({
    collection_id: c5.id,
    slug: '213',
    dpla: true,
    public: true,
    dc_title: [
        'Aerial View of City, Cordele, Georgia'
    ],
    dc_creator: [
        'Scenic South Card Company'
    ],
    dc_subject: [
        'Cordele (Ga.)--Aerial views',
        'Streets--Georgia--Cordele',
        'Buildings--Georgia--Cordele',
    ],
    dc_description: [
    ],
    dc_publisher: [
    ],
    dc_identifier: [
        'http://cdm.georgiaarchives.org:2011/cdm/singleitem/collection/postcard/id/213'
    ],
    dc_date: [
    ],
    dc_coverage_temporal: [
    ],
    dc_coverage_spatial: [
        'Cordele (Ga.)',
        'Crisp County (Ga.)',
    ],
    dc_contributor: [
        'Georgia Archives'
    ],
    dc_format: [
        'Visual image',
        'image/jpeg',
    ],
    dc_source: [
        'Historic Postcard Collection, RG 48-2-5, Georgia Archives',
    ],
    dc_relation: [
        'Historic Postcard Collection'
    ],
    dc_type: [
        'StillImage'
    ],
    dc_right: [
        'Postcards published after 1923 may be covered by copyright.  The Georgia Archives cannot provide permission to publish.',
    ]
})

i15 = Item.create!({
    collection_id: c5.id,
    slug: '431',
    dpla: true,
    public: true,
    dc_title: [
        'Aerial View of Fort Pulaski National Monument, Savannah, Georgia'
    ],
    dc_creator: [
        'Dixie News Company'
    ],
    dc_subject: [
        'Historic sites--Georgia--Cockspur Island',
        'Fortification--Georgia--Cockspur Island',
        'Moats--Georgia--Cockspur Island',
    ],
    dc_description: [
        'Fort Pulaski, on Cockspur Island, 17 miles from Savannah, was named in honor of Count Casimir Pulaski, who was mortally wounded at the Battle of Savannah in 1779.  The fort, surrounded by a wide moat, is 1580 feet in circumference.  The 7 to 11 feet thick solid brick walls are designed to mount two tiers of guns.  The fort, stronghold of bygone days, is open to visitors.'
    ],
    dc_publisher: [
    ],
    dc_identifier: [
        'http://cdm.georgiaarchives.org:2011/cdm/singleitem/collection/postcard/id/431'
    ],
    dc_date: [
    ],
    dc_coverage_temporal: [
    ],
    dc_coverage_spatial: [
        'Cockspur Island (Ga.)',
        'Chatham County (Ga.)',
    ],
    dc_contributor: [
        'Georgia Archives'
    ],
    dc_format: [
        'Visual image',
        'image/jpeg',
    ],
    dc_source: [
        'Historic Postcard Collection, RG 48-2-5, Georgia Archives',
    ],
    dc_relation: [
        'Historic Postcard Collection'
    ],
    dc_type: [
        'StillImage'
    ],
    dc_right: [
        'Postcards published after 1923 may be covered by copyright.  The Georgia Archives cannot provide permission to publish.',
    ]
})

i16 = Item.create!({
    collection_id: c5.id,
    slug: '444',
    dpla: true,
    public: true,
    dc_title: [
        'Aerial View of Main Business Section, Savannah, Georgia'
    ],
    dc_creator: [
        'Dixie News Company'
    ],
    dc_subject: [
        'Savannah (Ga.)--Aerial views',
        'Buildings--Georgia--Savannah',
        'Central business districts--Georgia--Savannah',
    ],
    dc_description: [
        'Historic and Beautiful Savannah, Birthplace of Georgia, is situated on a deep landlocked harbor at the head of ocean navigation on the Savannah River. More cotton is shipped from here than from any other Atlantic port, and it is the leading export city of the world for naval stores.  In Christ Church, on the side of John Wesley\'s Chapel, was held the first Protestant Sunday School in America.  Wormsloe Gardens, on the south end of the Isle of Hope are the most beautiful in the South.'
    ],
    dc_publisher: [
    ],
    dc_identifier: [
        'http://cdm.georgiaarchives.org:2011/cdm/singleitem/collection/postcard/id/444'
    ],
    dc_date: [
    ],
    dc_coverage_temporal: [
    ],
    dc_coverage_spatial: [
        'Savannah (Ga.)',
        'Chatham County (Ga.)',
    ],
    dc_contributor: [
        'Georgia Archives'
    ],
    dc_format: [
        'Visual image',
        'image/jpeg',
    ],
    dc_source: [
        'Historic Postcard Collection, RG 48-2-5, Georgia Archives',
        'Postcards published after 1923 may be covered by copyright.  The Georgia Archives cannot provide permission to publish.',
    ],
    dc_relation: [
        'Historic Postcard Collection'
    ],
    dc_type: [
        'StillImage'
    ],
    dc_right: [
    ]
})

Collection.reindex
Item.reindex