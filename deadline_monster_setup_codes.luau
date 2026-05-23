-- # Player Setup Codes Module
local SETUPS = {
    primary = {
        -- Gunlimits
        {
            Name = "HK416",
            WeaponCode = "KF416",
            SetupCode = "h945-0252-fde0-ag3h-0ddz-qmo1-b5cm-cbnm"
        },
        {
            Name = "MK16",
            WeaponCode = "SCARL",
            SetupCode = "o9oa-0252-w69f-0nan-m98q-4fc1-d47q-1g2o"
        },
        {
            Name = "MK17",
            WeaponCode = "SCARH",
            SetupCode = "df74-0252-zbm4-80mg-0bf9-fm7n-2g85-q9fd"
        },
        -- Nogunlimits
        {
            Name = "LSW-556",
            WeaponCode = "SA58",
            SetupCode = "4o7n-0252-dhen-23g4-2c87-cmm8-h112-8fg5"
        },
        {
            Name = "AK-102",
            WeaponCode = "AK_545",
            SetupCode = "3nh6-0252-6a3e-n81b-bo2c-f8he-q6eb-8ed7"
        },
        {
            Name = "AK-104",
            WeaponCode = "AK_545",
            SetupCode = "eqqz-0252-he3f-32fd-bhed-hqe5-hn89-m533"
        },
        {
            Name = "AK-105",
            WeaponCode = "AK_545",
            SetupCode = "4g93-0252-fg76-gz2m-e4g0-09aw-8z32-o5z4"
        },
        {
            Name = "AK308k-SD",
            WeaponCode = "AK308",
            SetupCode = "09q4-0252-d3em-5wzw-4cmm-6w2w-12h5-nbdf"
        },
        {
            Name = "HK433",
            WeaponCode = "KF416",
            SetupCode = "22oc-0252-5q19-9geq-915w-nn4f-no3f-43zf"
        },
        {
            Name = "MCX LVAW",
            WeaponCode = "M4A1",
            SetupCode = "bn1g-0252-d0hc-419f-cc93-cm2b-fg2e-498o"
        },
        {
            Name = "Super Duty M4",
            WeaponCode = "M4A1",
            SetupCode = "w74n-0252-f4ac-a7mz-n93c-o2n1-3146-7mg1"
        },
        {
            Name = "MK18 w/ M203",
            WeaponCode = "M4A1",
            SetupCode = "hnfd-0252-326e-8589-603c-6zd4-bn6q-eeqa"
        },
        {
            Name = "PKM",
            WeaponCode = "AK_762",
            SetupCode = "2neq-0252-m6qd-ndb6-wnm0-az6h-17oz-80wn"
        },
        {
            Name = "PTR-308",
            WeaponCode = "G3",
            SetupCode = "9na5-0252-2542-706z-w288-eaw4-a7w7-6f2f"
        },
        {
            Name = "QBB-556",
            WeaponCode = "QBZ95",
            SetupCode = "a1fz-0252-5gch-3h4b-d1bd-27g3-gaca-0543"
        },
        {
            Name = "RFB-308",
            WeaponCode = "QBZ95",
            SetupCode = "2gzw-0252-2chb-02nf-wo3d-m0gg-h7ng-foz9"
        },
        {
            Name = "RPK-308",
            WeaponCode = "AK308",
            SetupCode = "ad9o-0252-93q0-1bb0-hfz9-oobw-bcda-dhm8"
        },
        {
            Name = "SA-58 OSW",
            WeaponCode = "SA58",
            SetupCode = "2w29-0252-g9gf-og72-9wd0-5nbw-o59f-oam7"
        },
        {
            Name = "SCAR308k-SD",
            WeaponCode = "SCAR47",
            SetupCode = "oh75-0252-0w8g-gm78-e184-0ob6-1n6q-g910"
        },
        {
            Name = "SG553",
            WeaponCode = "AK_545",
            SetupCode = "f6c7-0252-qqeo-n8wd-zhq0-5gh3-gn06-9wn5"
        },
        {
            Name = "V308",
            WeaponCode = "Vector",
            SetupCode = "0m5d-0252-8zbe-ac2d-9mmb-eb5o-ww06-fbg6"
        },
    },
    secondary = {
        -- Gunlimits
        {
            Name = "416C",
            WeaponCode = "KF416",
            SetupCode = "z5hf-0252-n2qe-7f7d-b89o-cq1c-ec1f-01gq"
        },
        {
            Name = "AKS-74U",
            WeaponCode = "AK_545_Carbine",
            SetupCode = "00ba-0252-goqg-b10o-z760-ogb1-c3oa-9355"
        },
        {
            Name = "Short MK9",
            WeaponCode = "MK9",
            SetupCode = "o2d9-0252-0m41-ana8-1n5q-wdb1-4wf0-owa3"
        },
        {
            Name = "MP5",
            WeaponCode = "MP5",
            SetupCode = "63a3-0252-1n00-wefo-c13o-oahh-2z8a-1dne"
        },
        
        {
            Name = "PP-19-01",
            WeaponCode = "AK-9",
            SetupCode = "g0qa-0252-7dzn-0mgg-f66d-eo51-w6mo-hgw9"
        },
        -- Nogunlimits
        {
            Name = "MP/15 Hybrid Carbine",
            WeaponCode = "M4A1",
            SetupCode = "750o-0252-1447-n8q3-2o6h-0fz3-b7fn-g21n"
        },
        {
            Name = "P320 Carbine",
            WeaponCode = "P320",
            SetupCode = "q2f2-0252-bbm5-81do-5eoa-3anc-f840-8d53"
        },
        {
            Name = "P320 Carbine Mk. 2",
            WeaponCode = "P320",
            SetupCode = "a8nh-0252-aoqd-2h0z-h1fh-wq7h-a9cq-ca07"
        },
        {
            Name = "P320 Carbine Prototype",
            WeaponCode = "P320",
            SetupCode = "80o2-0252-81b0-nz20-dwom-a33w-92o5-fn8o"
        },
        {
            Name = "P320 Compact Carbine",
            WeaponCode = "P320",
            SetupCode = "92ca-0252-816h-qoeb-6qf9-hdgd-ofob-qcd7"
        },
        {
            Name = "UMP45-SD",
            WeaponCode = "UMP",
            SetupCode = "6aq4-0252-6hwe-qd8e-qna9-zz20-q74q-0mzb"
        },
    }
}

return SETUPS