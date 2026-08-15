-- # Player Setup Codes Module
local SETUPS = {
    primary = {
        -- Gunlimits, updated
        {
            Name = "HK416",
            WeaponCode = "KF416",
            SetupCode = "3c1b-0253-a0qm-00aa-gdn0-5dme-zd8w-7dqz"
        },
        {
            Name = "MK16 SC",
            WeaponCode = "SCARL",
            SetupCode = "f62b-0253-on3h-3d3q-6a04-0mnc-3q3o-09h3"
        },
        {
            Name = "MK17",
            WeaponCode = "SCARH",
            SetupCode = "wmwc-0253-1nzn-0aw7-3ge8-o2z0-bbe8-hoge"
        },
        {
            Name = "VLtor M4A1",
            WeaponCode = "M4A1",
            SetupCode = "2cg0-0253-fo7c-69gb-n06b-og1w-eq9a-967bf"
        },
        {
            Name = "VLtor Integral M4A1",
            WeaponCode = "M4A1",
            SetupCode = "3a8w-0253-qbeo-qz0e-cm05-w03c-bngd-3oe5"
        },
        -- Nogunlimits
        {
            Name = "AK-102",
            WeaponCode = "AK_545",
            SetupCode = "o1zc-0252-7m1f-9mdd-endh-nnn2-8eea-7g5z" -- normal: 3nh6-0252-6a3e-n81b-bo2c-f8he-q6eb-8ed7
        },
        {
            Name = "AK-104",
            WeaponCode = "AK_545",
            SetupCode = "eqqz-0252-he3f-32fd-bhed-hqe5-hn89-m533"
        },
        {
            Name = "AK-205",
            WeaponCode = "AK_545",
            SetupCode = "eqf2-0252-g2cg-5bfa-989h-q7ne-6oqa-ewa8"
        },
        {
            Name = "AK-308k",
            WeaponCode = "AK308",
            SetupCode = "b86o-0252-ff2n-mw46-4hg8-4c0w-104z-wze3"
        },
        {
            Name = "ASM-VAL",
            WeaponCode = "AK_545",
            SetupCode = "fe87-0252-9bad-z588-c1e5-a97q-m504-e1eh"
        },
        {
            Name = "AUG-762",
            WeaponCode = "AUG_A3",
            SetupCode = "60fh-0252-dc8m-qda4-om5z-z1qh-nh93-8n74"
        },
        {
            Name = "F2000",
            WeaponCode = "M4A1",
            SetupCode = "g20q-0252-b338-gaz3-eaq2-1meo-g427-327q"
        },
        {
            Name = "HK417 Prototype",
            WeaponCode = "KF416",
            SetupCode = "qcc6-0252-5w0z-34dm-bfcg-5emc-a67o-3mm0"
        },
        {
            Name = "HK433",
            WeaponCode = "KF416",
            SetupCode = "22oc-0252-5q19-9geq-915w-nn4f-no3f-43zf"
        },
        {
            Name = "LSW-556",
            WeaponCode = "SA58",
            SetupCode = "4o7n-0252-dhen-23g4-2c87-cmm8-h112-8fg5"
        },
        {
            Name = "M700",
            WeaponCode = "Remington700",
            SetupCode = "1naq-0252-0f4a-z2o4-58ee-ne4a-ahd6-obda"
        },
        {
            Name = "M870",
            WeaponCode = "Remington870",
            SetupCode = "9bo0-0252-b7fg-b7df-dm1d-wa47-ba0z-gg08"
        },
        {
            Name = "MCX LVAW",
            WeaponCode = "KF416",
            SetupCode = "d935-0252-809b-248a-3ego-aq05-3nmf-14dw"
        },
        {
            Name = "Super Duty M4",
            WeaponCode = "M4A1",
            SetupCode = "ma99-0252-7wzd-w5b6-o67w-6qoe-g0az-779c"
        },
        {
            Name = "Mk18 LSW",
            WeaponCode = "M4A1",
            SetupCode = "2c1z-0252-za29-wqz5-4hdw-qfgh-43o7-nf6g"
        },
        {
            Name = "Mk18 w/ M203",
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
            SetupCode = "a554-0252-4778-89zw-h232-gge1-fg00-1fhm"
        },
        {
            Name = "QBB-556",
            WeaponCode = "QBZ95",
            SetupCode = "a1fz-0252-5gch-3h4b-d1bd-27g3-gaca-0543"
        },
        {
            Name = "QBZ-192",
            WeaponCode = "AK_545",
            SetupCode = "35ez-0252-38c0-3eff-qbd4-8d93-60q1-q3df"
        },
        {
            Name = "RFB-308",
            WeaponCode = "QBZ95",
            SetupCode = "2gzw-0252-2chb-02nf-wo3d-m0gg-h7ng-foz9"
        },
        {
            Name = "RPK-15",
            WeaponCode = "AK308",
            SetupCode = "h03w-0252-a865-n80o-d947-4bn2-n74o-nzbo"
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
        {
            Name = "VLtor MK17",
            WeaponCode = "SCARH",
            SetupCode = "40c9-0252-37b5-w76b-hg28-34cm-0dcf-1nbe"
        },
        {
            Name = "VLtor SA-58",
            WeaponCode = "SA58",
            SetupCode = "8g1e-0252-0bz3-5bhc-g0zq-g5d3-z7fh-ogaf"
        },
    },
    secondary = {
        -- Gunlimits
        {
            Name = "416C",
            WeaponCode = "KF416",
            SetupCode = "fnfq-0252-w59b-e4ac-qzd1-b5q2-3hn3-ca4m"
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
            WeaponCode = "AK_9",
            SetupCode = "g0qa-0252-7dzn-0mgg-f66d-eo51-w6mo-hgw9"
        },
        -- Nogunlimits
        {
            Name = "SCAR-SC 10mm",
            WeaponCode = "SCARL",
            SetupCode = "0d35-0252-n87a-hmz0-h43b-n949-bqnf-m6ff"
        },
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
            Name = "SA-58 Pistol",
            WeaponCode = "SA58",
            SetupCode = "ohgq-0252-ah0z-471e-32b0-12zg-zade-n6wz"
        },
        {
            Name = "UMP45-SD",
            WeaponCode = "UMP",
            SetupCode = "6aq4-0252-6hwe-qd8e-qna9-zz20-q74q-0mzb"
        },
    }
}

return SETUPS