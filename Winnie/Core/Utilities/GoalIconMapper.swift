import Foundation

/// Maps goal name keywords to SF Symbols and infers GoalType for storage.
///
/// **How It Works:**
/// - Scans the goal name for keywords (case-insensitive)
/// - Returns the first matching SF Symbol, or a default star icon
/// - Also infers which GoalType category best fits for data storage
///
/// **Usage:**
/// ```swift
/// let icon = GoalIconMapper.icon(for: "Down Payment")  // Returns "house.fill"
/// let type = GoalIconMapper.inferGoalType(from: "Down Payment")  // Returns .house
/// ```
struct GoalIconMapper {

    // MARK: - Keyword to Icon Mapping

    /// Dictionary mapping keywords (lowercased) to SF Symbol names.
    /// Order matters for multi-word keywords - check longer phrases first.
    private static let keywordToIcon: [(keyword: String, icon: String)] = [

        // ═══════════════════════════════════════════════════════════════
        // HOUSE & REAL ESTATE
        // ═══════════════════════════════════════════════════════════════

        // Multi-word phrases first
        ("down payment", "house.fill"),
        ("first home", "house.fill"),
        ("new home", "house.fill"),
        ("dream home", "house.fill"),
        ("lake house", "house.lodge.fill"),
        ("beach house", "house.lodge.fill"),
        ("vacation home", "house.lodge.fill"),
        ("rental property", "building.2.crop.circle.fill"),
        ("investment property", "building.2.fill"),
        ("security deposit", "key.fill"),

        // Single words
        ("mortgage", "house.fill"),
        ("house", "house.fill"),
        ("home", "house.fill"),
        ("property", "house.fill"),
        ("apartment", "building.2.fill"),
        ("flat", "building.2.fill"),  // British
        ("condo", "building.2.fill"),
        ("townhouse", "building.2.fill"),
        ("duplex", "building.2.fill"),
        ("cabin", "house.lodge.fill"),
        ("cottage", "house.lodge.fill"),
        ("land", "map.fill"),
        ("acreage", "map.fill"),
        ("lot", "map.fill"),
        ("timeshare", "calendar"),
        ("airbnb", "bed.double.fill"),
        ("rent", "key.fill"),

        // ═══════════════════════════════════════════════════════════════
        // TRANSPORTATION & VEHICLES
        // ═══════════════════════════════════════════════════════════════

        // Multi-word phrases first
        ("electric car", "bolt.car.fill"),
        ("new car", "car.fill"),
        ("used car", "car.fill"),
        ("car loan", "car.fill"),
        ("auto loan", "car.fill"),
        ("electric bike", "bicycle"),
        ("jet ski", "water.waves"),
        ("four wheeler", "car.side.fill"),

        // Single words
        ("tesla", "bolt.car.fill"),
        ("ev", "bolt.car.fill"),
        ("car", "car.fill"),
        ("vehicle", "car.fill"),
        ("auto", "car.fill"),
        ("suv", "car.side.fill"),
        ("minivan", "car.side.fill"),
        ("convertible", "car.fill"),
        ("truck", "truck.box.fill"),
        ("lorry", "truck.box.fill"),  // British
        ("pickup", "truck.box.fill"),
        ("motorcycle", "bicycle"),
        ("motorbike", "bicycle"),
        ("scooter", "scooter"),
        ("moped", "scooter"),
        ("bike", "bicycle"),
        ("ebike", "bicycle"),
        ("bicycle", "bicycle"),
        ("boat", "sailboat.fill"),
        ("yacht", "sailboat.fill"),
        ("sailboat", "sailboat.fill"),
        ("rv", "bus.fill"),
        ("motorhome", "bus.fill"),
        ("camper", "bus.fill"),
        ("trailer", "bus.fill"),
        ("atv", "car.side.fill"),

        // ═══════════════════════════════════════════════════════════════
        // TRAVEL & VACATION
        // ═══════════════════════════════════════════════════════════════

        // Multi-word destination phrases first
        ("ski trip", "figure.skiing.downhill"),
        ("road trip", "car.fill"),
        ("camping trip", "tent.fill"),
        ("italy trip", "fork.knife"),
        ("new york", "building.2.fill"),
        ("las vegas", "suit.spade.fill"),
        ("theme park", "sparkles"),
        ("amusement park", "sparkles"),
        ("national park", "leaf.fill"),

        // Destinations
        ("disney", "sparkles"),
        ("disneyland", "sparkles"),
        ("disneyworld", "sparkles"),
        ("vegas", "suit.spade.fill"),
        ("paris", "building.columns.fill"),
        ("france", "building.columns.fill"),
        ("europe", "globe.europe.africa.fill"),
        ("london", "clock.fill"),
        ("england", "clock.fill"),
        ("uk", "clock.fill"),
        ("japan", "leaf.fill"),
        ("tokyo", "leaf.fill"),
        ("hawaii", "sun.max.fill"),
        ("tropical", "sun.max.fill"),
        ("caribbean", "beach.umbrella.fill"),
        ("bahamas", "beach.umbrella.fill"),
        ("jamaica", "beach.umbrella.fill"),
        ("mexico", "sun.max.fill"),
        ("cancun", "sun.max.fill"),
        ("italy", "fork.knife"),
        ("rome", "building.columns.fill"),
        ("greece", "building.columns.fill"),
        ("spain", "sun.max.fill"),
        ("australia", "globe.asia.australia.fill"),
        ("asia", "globe.asia.australia.fill"),
        ("africa", "pawprint.fill"),
        ("safari", "pawprint.fill"),
        ("nyc", "building.2.fill"),
        ("aspen", "figure.skiing.downhill"),
        ("vail", "figure.skiing.downhill"),
        ("colorado", "mountain.2.fill"),

        // Travel types
        ("vacation", "airplane"),
        ("vacay", "airplane"),  // Slang
        ("vaca", "airplane"),  // Slang
        ("holiday", "airplane"),  // British
        ("hols", "airplane"),  // British slang
        ("travel", "airplane"),
        ("trip", "airplane"),
        ("flight", "airplane"),
        ("getaway", "airplane"),
        ("cruise", "ferry.fill"),
        ("beach", "beach.umbrella.fill"),
        ("backpacking", "backpack.fill"),
        ("staycation", "house.fill"),
        ("workcation", "laptopcomputer"),

        // ═══════════════════════════════════════════════════════════════
        // EDUCATION
        // ═══════════════════════════════════════════════════════════════

        // Multi-word first
        ("student loan", "graduationcap.fill"),
        ("grad school", "graduationcap.fill"),
        ("law school", "building.columns.fill"),
        ("med school", "stethoscope"),
        ("online course", "play.rectangle.fill"),

        // Single words
        ("college", "graduationcap.fill"),
        ("university", "graduationcap.fill"),
        ("uni", "graduationcap.fill"),  // British
        ("tuition", "graduationcap.fill"),
        ("degree", "graduationcap.fill"),
        ("mba", "graduationcap.fill"),
        ("phd", "graduationcap.fill"),
        ("masters", "graduationcap.fill"),
        ("education", "book.fill"),
        ("school", "book.fill"),
        ("academy", "book.fill"),
        ("student", "graduationcap.fill"),
        ("scholarship", "graduationcap.fill"),
        ("certification", "checkmark.seal.fill"),
        ("certificate", "checkmark.seal.fill"),
        ("bootcamp", "laptopcomputer"),
        ("course", "play.rectangle.fill"),
        ("training", "person.fill.checkmark"),
        ("workshop", "wrench.and.screwdriver.fill"),
        ("seminar", "person.3.fill"),
        ("conference", "person.3.fill"),
        ("books", "books.vertical.fill"),
        ("textbook", "book.fill"),
        ("tutoring", "book.fill"),
        ("lessons", "book.fill"),
        ("language", "character.book.closed.fill"),

        // ═══════════════════════════════════════════════════════════════
        // FAMILY & LIFE EVENTS
        // ═══════════════════════════════════════════════════════════════

        // Multi-word first
        ("baby fund", "figure.2.and.child.holdinghands"),
        ("baby shower", "gift.fill"),
        ("bar mitzvah", "star.of.david.fill"),
        ("bat mitzvah", "star.of.david.fill"),
        ("sweet sixteen", "birthday.cake.fill"),

        // Single words
        ("baby", "figure.2.and.child.holdinghands"),
        ("child", "figure.2.and.child.holdinghands"),
        ("children", "figure.2.and.child.holdinghands"),
        ("kid", "figure.2.and.child.holdinghands"),
        ("kids", "figure.2.and.child.holdinghands"),
        ("family", "figure.2.and.child.holdinghands"),
        ("toddler", "figure.2.and.child.holdinghands"),
        ("newborn", "figure.2.and.child.holdinghands"),
        ("nursery", "figure.2.and.child.holdinghands"),
        ("daycare", "figure.and.child.holdinghands"),
        ("childcare", "figure.and.child.holdinghands"),
        ("nanny", "figure.and.child.holdinghands"),
        ("pram", "figure.2.and.child.holdinghands"),  // British
        ("buggy", "figure.2.and.child.holdinghands"),  // British
        ("stroller", "figure.2.and.child.holdinghands"),
        ("wedding", "heart.fill"),
        ("marriage", "heart.fill"),
        ("engagement", "heart.circle.fill"),
        ("honeymoon", "heart.fill"),
        ("anniversary", "heart.fill"),
        ("ring", "heart.circle.fill"),
        ("proposal", "heart.circle.fill"),
        ("bridal", "heart.fill"),
        ("bachelor", "party.popper.fill"),
        ("bachelorette", "party.popper.fill"),
        ("quinceañera", "sparkles"),
        ("quince", "sparkles"),
        ("adoption", "figure.2.and.child.holdinghands"),
        ("adopt", "figure.2.and.child.holdinghands"),
        ("fertility", "figure.2.and.child.holdinghands"),
        ("ivf", "figure.2.and.child.holdinghands"),
        ("surrogacy", "figure.2.and.child.holdinghands"),
        ("maternity", "figure.2.and.child.holdinghands"),
        ("paternity", "figure.2.and.child.holdinghands"),

        // Kids activities
        ("camp", "tent.fill"),
        ("activities", "star.fill"),
        ("extracurricular", "star.fill"),
        ("braces", "face.smiling.fill"),
        ("orthodontist", "face.smiling.fill"),
        ("toys", "teddybear.fill"),
        ("playground", "figure.play"),
        ("allowance", "dollarsign.circle.fill"),

        // ═══════════════════════════════════════════════════════════════
        // EMERGENCY & SAFETY
        // ═══════════════════════════════════════════════════════════════

        // Multi-word first
        ("rainy day", "cloud.rain.fill"),
        ("safety net", "shield.fill"),
        ("emergency fund", "shield.fill"),

        // Single words
        ("emergency", "shield.fill"),
        ("buffer", "shield.fill"),
        ("cushion", "shield.fill"),
        ("reserve", "shield.fill"),
        ("backup", "shield.fill"),
        ("savings", "banknote.fill"),

        // ═══════════════════════════════════════════════════════════════
        // DEBT PAYOFF
        // ═══════════════════════════════════════════════════════════════

        // Multi-word first
        ("credit card", "creditcard.fill"),
        ("pay off", "arrow.down.to.line.circle.fill"),
        ("mortgage payoff", "house.fill"),

        // Single words
        ("debt", "creditcard.fill"),
        ("payoff", "arrow.down.to.line.circle.fill"),
        ("loan", "banknote.fill"),
        ("credit", "creditcard.fill"),
        ("balance", "scale.3d"),
        ("consolidation", "arrow.triangle.merge"),
        ("interest", "percent"),

        // ═══════════════════════════════════════════════════════════════
        // RETIREMENT & INVESTING
        // ═══════════════════════════════════════════════════════════════

        // Single words
        ("retirement", "chart.line.uptrend.xyaxis"),
        ("retire", "chart.line.uptrend.xyaxis"),
        ("401k", "chart.line.uptrend.xyaxis"),
        ("403b", "chart.line.uptrend.xyaxis"),
        ("ira", "chart.line.uptrend.xyaxis"),
        ("roth", "chart.line.uptrend.xyaxis"),
        ("pension", "chart.line.uptrend.xyaxis"),
        ("investment", "chart.bar.fill"),
        ("investing", "chart.bar.fill"),
        ("portfolio", "chart.bar.fill"),
        ("stocks", "chart.xyaxis.line"),
        ("stock", "chart.xyaxis.line"),
        ("bonds", "chart.bar.fill"),
        ("etf", "chart.bar.fill"),
        ("mutual fund", "chart.bar.fill"),
        ("dividends", "dollarsign.arrow.circlepath"),
        ("compound", "chart.line.uptrend.xyaxis"),
        ("wealth", "banknote.fill"),
        ("nest egg", "banknote.fill"),
        ("passive income", "dollarsign.arrow.circlepath"),

        // ═══════════════════════════════════════════════════════════════
        // BUSINESS & CAREER
        // ═══════════════════════════════════════════════════════════════

        // Multi-word first
        ("side hustle", "laptopcomputer.and.iphone"),
        ("career change", "arrow.triangle.2.circlepath"),
        ("new job", "briefcase.fill"),
        ("gap year", "globe.americas.fill"),
        ("quit job", "figure.walk.departure"),

        // Single words
        ("business", "briefcase.fill"),
        ("startup", "lightbulb.fill"),
        ("entrepreneur", "lightbulb.fill"),
        ("freelance", "laptopcomputer.and.iphone"),
        ("consulting", "person.fill.checkmark"),
        ("sabbatical", "moon.zzz.fill"),
        ("networking", "person.3.fill"),
        ("career", "briefcase.fill"),
        ("office", "building.2.fill"),
        ("equipment", "wrench.and.screwdriver.fill"),

        // ═══════════════════════════════════════════════════════════════
        // ELECTRONICS & TECH
        // ═══════════════════════════════════════════════════════════════

        // Multi-word first
        ("pc gaming", "desktopcomputer"),
        ("gaming pc", "desktopcomputer"),
        ("virtual reality", "visionpro"),

        // Single words
        ("computer", "laptopcomputer"),
        ("laptop", "laptopcomputer"),
        ("macbook", "laptopcomputer"),
        ("desktop", "desktopcomputer"),
        ("phone", "iphone"),
        ("iphone", "iphone"),
        ("android", "iphone"),
        ("smartphone", "iphone"),
        ("mac", "desktopcomputer"),
        ("imac", "desktopcomputer"),
        ("tablet", "ipad"),
        ("ipad", "ipad"),
        ("tv", "tv.fill"),
        ("television", "tv.fill"),
        ("monitor", "display"),
        ("display", "display"),
        ("headphones", "headphones"),
        ("airpods", "airpods"),
        ("speaker", "hifispeaker.fill"),
        ("camera", "camera.fill"),
        ("photography", "camera.fill"),
        ("photo", "camera.fill"),
        ("lens", "camera.aperture"),
        ("dslr", "camera.fill"),
        ("drone", "airplane"),
        ("vr", "visionpro"),
        ("gaming", "gamecontroller.fill"),
        ("console", "gamecontroller.fill"),
        ("playstation", "gamecontroller.fill"),
        ("xbox", "gamecontroller.fill"),
        ("nintendo", "gamecontroller.fill"),
        ("switch", "gamecontroller.fill"),

        // ═══════════════════════════════════════════════════════════════
        // HEALTH & MEDICAL
        // ═══════════════════════════════════════════════════════════════

        // Multi-word first
        ("mental health", "brain.head.profile"),
        ("plastic surgery", "cross.case.fill"),
        ("cosmetic surgery", "cross.case.fill"),

        // Single words
        ("medical", "cross.case.fill"),
        ("surgery", "cross.case.fill"),
        ("operation", "cross.case.fill"),
        ("procedure", "cross.case.fill"),
        ("hospital", "cross.case.fill"),
        ("health", "heart.text.square.fill"),
        ("healthcare", "heart.text.square.fill"),
        ("dental", "face.smiling"),
        ("teeth", "face.smiling"),
        ("invisalign", "face.smiling"),
        ("doctor", "stethoscope"),
        ("therapy", "brain.head.profile"),
        ("therapist", "brain.head.profile"),
        ("counseling", "brain.head.profile"),
        ("psychologist", "brain.head.profile"),
        ("psychiatrist", "brain.head.profile"),
        ("vision", "eye.fill"),
        ("lasik", "eye.fill"),
        ("glasses", "eyeglasses"),
        ("eyewear", "eyeglasses"),
        ("contacts", "eye.fill"),
        ("hearing", "ear.fill"),
        ("fertility", "figure.2.and.child.holdinghands"),
        ("pregnancy", "figure.2.and.child.holdinghands"),

        // ═══════════════════════════════════════════════════════════════
        // FITNESS & WELLNESS
        // ═══════════════════════════════════════════════════════════════

        // Multi-word first
        ("home gym", "dumbbell.fill"),

        // Single words
        ("gym", "dumbbell.fill"),
        ("fitness", "dumbbell.fill"),
        ("workout", "figure.strengthtraining.traditional"),
        ("exercise", "figure.strengthtraining.traditional"),
        ("peloton", "figure.indoor.cycle"),
        ("spin", "figure.indoor.cycle"),
        ("treadmill", "figure.run.treadmill"),
        ("weights", "dumbbell.fill"),
        ("dumbbell", "dumbbell.fill"),
        ("yoga", "figure.yoga"),
        ("pilates", "figure.yoga"),
        ("crossfit", "figure.cross.training"),
        ("marathon", "medal.fill"),
        ("race", "medal.fill"),
        ("triathlon", "medal.fill"),
        ("trainer", "person.fill.checkmark"),
        ("coaching", "person.fill.checkmark"),
        ("coach", "person.fill.checkmark"),
        ("spa", "sparkles"),
        ("massage", "sparkles"),
        ("wellness", "sparkles"),
        ("retreat", "leaf.fill"),

        // ═══════════════════════════════════════════════════════════════
        // SPORTS & OUTDOOR
        // ═══════════════════════════════════════════════════════════════

        // Single words
        ("golf", "figure.golf"),
        ("tennis", "tennis.racket"),
        ("skiing", "figure.skiing.downhill"),
        ("ski", "figure.skiing.downhill"),
        ("snowboard", "figure.snowboarding"),
        ("snowboarding", "figure.snowboarding"),
        ("surf", "figure.surfing"),
        ("surfing", "figure.surfing"),
        ("surfboard", "figure.surfing"),
        ("skateboard", "figure.skating"),
        ("skating", "figure.skating"),
        ("basketball", "basketball.fill"),
        ("soccer", "soccerball"),
        ("football", "football.fill"),
        ("baseball", "baseball.fill"),
        ("hockey", "hockey.puck.fill"),
        ("swimming", "figure.pool.swim"),
        ("swim", "figure.pool.swim"),
        ("running", "figure.run"),
        ("run", "figure.run"),
        ("jogging", "figure.run"),
        ("cycling", "figure.outdoor.cycle"),
        ("cycle", "figure.outdoor.cycle"),
        ("climbing", "figure.climbing"),
        ("bouldering", "figure.climbing"),
        ("hiking", "figure.hiking"),
        ("hike", "figure.hiking"),
        ("fishing", "fish.fill"),
        ("hunting", "scope"),
        ("archery", "scope"),
        ("camping", "tent.fill"),
        ("outdoor", "mountain.2.fill"),
        ("mountain", "mountain.2.fill"),
        ("mountaineering", "mountain.2.fill"),
        ("kayak", "sailboat.fill"),
        ("canoe", "sailboat.fill"),
        ("paddle", "sailboat.fill"),
        ("rowing", "figure.rowing"),

        // ═══════════════════════════════════════════════════════════════
        // HOBBIES & MUSIC
        // ═══════════════════════════════════════════════════════════════

        // Music
        ("guitar", "guitars.fill"),
        ("bass", "guitars.fill"),
        ("piano", "pianokeys"),
        ("keyboard", "pianokeys"),
        ("drums", "drum.fill"),
        ("percussion", "drum.fill"),
        ("instrument", "music.note"),
        ("music", "music.note"),
        ("vinyl", "opticaldisc.fill"),
        ("records", "opticaldisc.fill"),
        ("turntable", "opticaldisc.fill"),
        ("concert", "music.mic"),
        ("festival", "music.mic"),
        ("show", "music.mic"),
        ("gig", "music.mic"),

        // Art & Craft
        ("art", "paintpalette.fill"),
        ("painting", "paintpalette.fill"),
        ("canvas", "paintpalette.fill"),
        ("craft", "scissors"),
        ("crafting", "scissors"),
        ("diy", "wrench.and.screwdriver.fill"),
        ("sewing", "scissors"),
        ("knitting", "scissors"),
        ("pottery", "paintpalette.fill"),
        ("woodworking", "hammer.fill"),

        // Collectibles
        ("collection", "square.grid.3x3.fill"),
        ("collectible", "square.grid.3x3.fill"),
        ("cards", "rectangle.stack.fill"),
        ("trading cards", "rectangle.stack.fill"),
        ("coins", "centsign.circle.fill"),
        ("numismatic", "centsign.circle.fill"),
        ("antiques", "clock.fill"),
        ("vintage", "clock.fill"),
        ("memorabilia", "star.circle.fill"),
        ("comics", "book.fill"),
        ("stamps", "rectangle.stack.fill"),

        // ═══════════════════════════════════════════════════════════════
        // FASHION & PERSONAL
        // ═══════════════════════════════════════════════════════════════

        // Single words
        ("wardrobe", "tshirt.fill"),
        ("clothes", "tshirt.fill"),
        ("clothing", "tshirt.fill"),
        ("fashion", "tshirt.fill"),
        ("jewelry", "seal.fill"),
        ("jewellery", "seal.fill"),  // British
        ("watch", "applewatch"),
        ("watches", "applewatch"),
        ("rolex", "applewatch"),
        ("designer", "handbag.fill"),
        ("luxury", "handbag.fill"),
        ("handbag", "handbag.fill"),
        ("purse", "handbag.fill"),
        ("shoes", "shoe.fill"),
        ("sneakers", "shoe.fill"),
        ("boots", "shoe.fill"),
        ("heels", "shoe.fill"),
        ("cosmetic", "sparkle"),
        ("beauty", "sparkle"),
        ("makeup", "sparkle"),
        ("skincare", "sparkle"),
        ("hair", "scissors"),
        ("salon", "scissors"),

        // ═══════════════════════════════════════════════════════════════
        // ENTERTAINMENT
        // ═══════════════════════════════════════════════════════════════

        // Single words
        ("tickets", "ticket.fill"),
        ("event", "ticket.fill"),
        ("theater", "theatermasks.fill"),
        ("theatre", "theatermasks.fill"),  // British
        ("broadway", "theatermasks.fill"),
        ("movie", "film.fill"),
        ("cinema", "film.fill"),
        ("film", "film.fill"),
        ("streaming", "play.rectangle.fill"),
        ("subscription", "play.rectangle.fill"),
        ("netflix", "play.rectangle.fill"),
        ("spotify", "music.note"),
        ("entertainment", "sparkles"),

        // ═══════════════════════════════════════════════════════════════
        // FOOD & DINING
        // ═══════════════════════════════════════════════════════════════

        // Single words
        ("restaurant", "fork.knife"),
        ("dining", "fork.knife"),
        ("dinner", "fork.knife"),
        ("kitchen", "frying.pan.fill"),
        ("cooking", "frying.pan.fill"),
        ("appliances", "refrigerator.fill"),
        ("wine", "wineglass.fill"),
        ("cellar", "wineglass.fill"),
        ("coffee", "cup.and.saucer.fill"),
        ("espresso", "cup.and.saucer.fill"),
        ("bbq", "flame.fill"),
        ("grill", "flame.fill"),
        ("smoker", "flame.fill"),

        // ═══════════════════════════════════════════════════════════════
        // HOME IMPROVEMENT
        // ═══════════════════════════════════════════════════════════════

        // Single words
        ("renovation", "hammer.fill"),
        ("reno", "hammer.fill"),  // Slang
        ("remodel", "hammer.fill"),
        ("remodeling", "hammer.fill"),
        ("furniture", "sofa.fill"),
        ("couch", "sofa.fill"),
        ("sofa", "sofa.fill"),
        ("appliance", "refrigerator.fill"),
        ("refrigerator", "refrigerator.fill"),
        ("washer", "washer.fill"),
        ("dryer", "dryer.fill"),
        ("landscaping", "leaf.fill"),
        ("yard", "leaf.fill"),
        ("garden", "tree.fill"),
        ("gardening", "tree.fill"),
        ("pool", "drop.fill"),
        ("hottub", "bathtub.fill"),
        ("jacuzzi", "bathtub.fill"),
        ("roof", "house.fill"),
        ("roofing", "house.fill"),
        ("hvac", "fan.fill"),
        ("ac", "fan.fill"),
        ("heating", "flame.fill"),
        ("solar", "sun.max.fill"),
        ("security", "lock.shield.fill"),
        ("alarm", "bell.fill"),
        ("fence", "square.split.2x1.fill"),
        ("fencing", "square.split.2x1.fill"),
        ("flooring", "square.grid.2x2.fill"),
        ("carpet", "square.grid.2x2.fill"),
        ("bathroom", "shower.fill"),
        ("basement", "house.fill"),
        ("garage", "car.fill"),
        ("deck", "square.fill"),
        ("patio", "sun.max.fill"),

        // ═══════════════════════════════════════════════════════════════
        // PETS & ANIMALS
        // ═══════════════════════════════════════════════════════════════

        // Single words
        ("pet", "pawprint.fill"),
        ("pets", "pawprint.fill"),
        ("dog", "pawprint.fill"),
        ("puppy", "pawprint.fill"),
        ("cat", "pawprint.fill"),
        ("kitten", "pawprint.fill"),
        ("vet", "pawprint.fill"),
        ("veterinary", "pawprint.fill"),
        ("aquarium", "fish.fill"),
        ("fish", "fish.fill"),
        ("bird", "bird.fill"),
        ("horse", "figure.equestrian.sports"),
        ("equestrian", "figure.equestrian.sports"),

        // ═══════════════════════════════════════════════════════════════
        // ELDERLY CARE
        // ═══════════════════════════════════════════════════════════════

        // Multi-word first
        ("nursing home", "building.fill"),
        ("assisted living", "building.fill"),
        ("aging parents", "figure.2"),
        ("elder care", "figure.roll"),

        // Single words
        ("caregiver", "heart.fill"),
        ("caretaker", "heart.fill"),

        // ═══════════════════════════════════════════════════════════════
        // CHARITABLE & GIVING
        // ═══════════════════════════════════════════════════════════════

        // Single words
        ("donation", "heart.circle.fill"),
        ("donate", "heart.circle.fill"),
        ("charity", "hand.raised.fill"),
        ("charitable", "hand.raised.fill"),
        ("tithing", "building.columns.fill"),
        ("tithe", "building.columns.fill"),
        ("giving", "gift.fill"),
        ("philanthropy", "gift.fill"),
        ("nonprofit", "hands.sparkles.fill"),
        ("volunteer", "hands.sparkles.fill"),
        ("church", "building.columns.fill"),
        ("temple", "building.columns.fill"),
        ("mosque", "building.columns.fill"),
        ("synagogue", "star.of.david.fill"),

        // ═══════════════════════════════════════════════════════════════
        // LIFE TRANSITIONS & LEGAL
        // ═══════════════════════════════════════════════════════════════

        // Multi-word first
        ("first apartment", "door.left.hand.open"),
        ("new place", "door.left.hand.open"),

        // Single words
        ("moving", "shippingbox.fill"),
        ("move", "shippingbox.fill"),
        ("relocation", "arrow.right.arrow.left"),
        ("relocate", "arrow.right.arrow.left"),
        ("deposit", "key.fill"),
        ("divorce", "person.2.slash"),
        ("lawyer", "building.columns.fill"),
        ("attorney", "building.columns.fill"),
        ("legal", "building.columns.fill"),
        ("custody", "hand.raised.fill"),
        ("immigration", "doc.text.fill"),
        ("visa", "doc.text.fill"),
        ("passport", "doc.text.fill"),
        ("citizenship", "doc.text.fill"),
        ("funeral", "leaf.fill"),
        ("burial", "leaf.fill"),
        ("cremation", "leaf.fill"),
        ("estate", "doc.richtext.fill"),
        ("will", "doc.richtext.fill"),
        ("inheritance", "gift.fill"),
        ("quitting", "figure.walk.departure"),

        // ═══════════════════════════════════════════════════════════════
        // HOLIDAYS & SPECIAL OCCASIONS
        // ═══════════════════════════════════════════════════════════════

        // Multi-word first
        ("new year", "sparkles"),
        ("new years", "sparkles"),
        ("mothers day", "heart.fill"),
        ("mother's day", "heart.fill"),
        ("fathers day", "heart.fill"),
        ("father's day", "heart.fill"),
        ("independence day", "star.fill"),
        ("4th of july", "star.fill"),
        ("july 4th", "star.fill"),

        // Single words
        ("gift", "gift.fill"),
        ("gifts", "gift.fill"),
        ("present", "gift.fill"),
        ("christmas", "gift.fill"),
        ("xmas", "gift.fill"),  // Abbreviation
        ("holiday", "gift.fill"),
        ("hanukkah", "star.of.david.fill"),
        ("chanukah", "star.of.david.fill"),
        ("kwanzaa", "sparkles"),
        ("diwali", "light.max"),
        ("easter", "hare.fill"),
        ("thanksgiving", "leaf.fill"),
        ("halloween", "theatermasks.fill"),
        ("valentines", "heart.fill"),
        ("valentine", "heart.fill"),
        ("birthday", "birthday.cake.fill"),
        ("bday", "birthday.cake.fill"),  // Abbreviation
        ("party", "party.popper.fill"),
        ("celebration", "party.popper.fill"),
        ("graduation", "graduationcap.fill"),
        ("grad", "graduationcap.fill"),
        ("prom", "sparkles"),
        ("reunion", "person.3.fill"),
        ("shower", "gift.fill"),

        // ═══════════════════════════════════════════════════════════════
        // INSURANCE & TAXES
        // ═══════════════════════════════════════════════════════════════

        // Single words
        ("insurance", "shield.checkered"),
        ("taxes", "doc.text.fill"),
        ("tax", "doc.text.fill"),
        ("irs", "building.columns.fill"),
        ("accountant", "person.text.rectangle.fill"),
        ("cpa", "person.text.rectangle.fill"),

        // ═══════════════════════════════════════════════════════════════
        // MISCELLANEOUS
        // ═══════════════════════════════════════════════════════════════

        // Single words
        ("dream", "sparkles"),
        ("goal", "target"),
        ("future", "sparkles"),
        ("bucket list", "list.bullet"),
        ("milestone", "flag.fill"),
        ("project", "folder.fill"),
        ("fund", "banknote.fill"),
        ("purchase", "cart.fill"),
        ("upgrade", "arrow.up.circle.fill"),
        ("splurge", "sparkles"),
        ("treat", "sparkles"),
        ("reward", "star.fill"),
        ("surprise", "gift.fill"),
        ("adventure", "mountain.2.fill"),
        ("experience", "sparkles"),
        ("memory", "photo.fill"),
        ("memories", "photo.fill")
    ]

    /// Default icon when no keywords match.
    static let defaultIcon = "dollarsign.circle.fill"

    // MARK: - Public Methods

    /// Find the best matching SF Symbol for a goal name.
    ///
    /// - Parameter goalName: The user-entered goal name
    /// - Returns: An SF Symbol name that represents the goal
    static func icon(for goalName: String) -> String {
        let lowercased = goalName.lowercased()

        for (keyword, icon) in keywordToIcon {
            if keyword.contains(" ") {
                // Multi-word keyword: use simple substring match
                // These are specific enough that substring matching is fine
                if lowercased.contains(keyword) {
                    return icon
                }
            } else {
                // Single-word keyword: require word boundaries
                // This prevents "car" from matching inside "card"
                // \b matches word boundaries (spaces, punctuation, start/end of string)
                let pattern = "\\b\(NSRegularExpression.escapedPattern(for: keyword))\\b"
                if lowercased.range(of: pattern, options: .regularExpression) != nil {
                    return icon
                }
            }
        }

        return defaultIcon
    }

    /// Infer the GoalType category from a goal name for data storage.
    ///
    /// This ensures goals are properly categorized even with custom names,
    /// which affects default return rates and suggested savings vehicles.
    ///
    /// - Parameter goalName: The user-entered goal name
    /// - Returns: The most appropriate GoalType, defaulting to `.custom`
    static func inferGoalType(from goalName: String) -> GoalType {
        let lowercased = goalName.lowercased()

        // Debt-related (check first - high priority for financial planning)
        let debtKeywords = [
            "debt", "credit card", "loan", "payoff", "pay off", "balance",
            "consolidation", "interest"
        ]
        if matchesAnyKeyword(lowercased, keywords: debtKeywords) {
            return .debt
        }

        // House-related
        let houseKeywords = [
            "house", "home", "down payment", "mortgage", "property", "apartment",
            "condo", "flat", "townhouse", "duplex", "cabin", "cottage", "rent",
            "rental property", "investment property", "land", "acreage", "airbnb"
        ]
        if matchesAnyKeyword(lowercased, keywords: houseKeywords) {
            return .house
        }

        // Vehicle-related
        let carKeywords = [
            "car", "vehicle", "auto", "truck", "suv", "motorcycle", "motorbike",
            "scooter", "boat", "yacht", "rv", "motorhome", "camper", "tesla", "ev"
        ]
        if matchesAnyKeyword(lowercased, keywords: carKeywords) {
            return .car
        }

        // Retirement-related
        let retirementKeywords = [
            "retirement", "retire", "401k", "403b", "ira", "roth", "pension"
        ]
        if matchesAnyKeyword(lowercased, keywords: retirementKeywords) {
            return .retirement
        }

        // Investment-related
        let investmentKeywords = [
            "investment", "investing", "portfolio", "stocks", "stock", "bonds",
            "etf", "mutual fund", "dividends", "wealth", "passive income"
        ]
        if matchesAnyKeyword(lowercased, keywords: investmentKeywords) {
            return .investment
        }

        // Education-related
        let educationKeywords = [
            "college", "university", "uni", "tuition", "degree", "mba", "phd",
            "masters", "education", "school", "student", "scholarship",
            "certification", "bootcamp", "course", "training"
        ]
        if matchesAnyKeyword(lowercased, keywords: educationKeywords) {
            return .education
        }

        // Vacation-related
        let vacationKeywords = [
            "vacation", "vacay", "vaca", "holiday", "hols", "travel", "trip",
            "cruise", "beach", "flight", "hawaii", "honeymoon", "getaway",
            "disney", "europe", "paris", "japan", "caribbean", "mexico",
            "backpacking", "safari", "adventure"
        ]
        if matchesAnyKeyword(lowercased, keywords: vacationKeywords) {
            return .vacation
        }

        // Emergency-related
        let emergencyKeywords = [
            "emergency", "rainy day", "safety net", "buffer", "cushion",
            "reserve", "backup"
        ]
        if matchesAnyKeyword(lowercased, keywords: emergencyKeywords) {
            return .emergencyFund
        }

        // Fitness-related
        let fitnessKeywords = [
            "gym", "fitness", "workout", "exercise", "peloton", "treadmill",
            "weights", "yoga", "pilates", "crossfit", "marathon", "trainer",
            "wellness", "spa"
        ]
        if matchesAnyKeyword(lowercased, keywords: fitnessKeywords) {
            return .fitness
        }

        // Hobby-related
        let hobbyKeywords = [
            "gaming", "console", "playstation", "xbox", "nintendo", "guitar",
            "piano", "drums", "instrument", "music", "camera", "photography",
            "art", "painting", "craft", "collection", "collectible", "golf",
            "tennis", "skiing", "snowboard", "surfing", "fishing", "hunting",
            "camping", "hiking", "kayak", "woodworking"
        ]
        if matchesAnyKeyword(lowercased, keywords: hobbyKeywords) {
            return .hobby
        }

        // Gift/Celebration-related
        let giftKeywords = [
            "gift", "present", "christmas", "xmas", "birthday", "bday",
            "party", "celebration", "graduation", "anniversary", "valentine",
            "halloween", "thanksgiving", "easter", "hanukkah", "diwali"
        ]
        if matchesAnyKeyword(lowercased, keywords: giftKeywords) {
            return .gift
        }

        // Home Improvement-related
        let homeImprovementKeywords = [
            "renovation", "reno", "remodel", "furniture", "appliance",
            "landscaping", "garden", "pool", "roof", "hvac", "solar",
            "bathroom", "kitchen", "flooring", "fence", "deck", "patio"
        ]
        if matchesAnyKeyword(lowercased, keywords: homeImprovementKeywords) {
            return .homeImprovement
        }

        // Charity-related
        let charityKeywords = [
            "donation", "donate", "charity", "charitable", "tithing", "tithe",
            "giving", "philanthropy", "nonprofit", "volunteer", "church",
            "temple", "mosque", "synagogue"
        ]
        if matchesAnyKeyword(lowercased, keywords: charityKeywords) {
            return .charity
        }

        // Family-related (check later - more general)
        let familyKeywords = [
            "baby", "child", "children", "kid", "kids", "family", "wedding",
            "marriage", "engagement", "adoption", "fertility", "ivf",
            "daycare", "childcare", "nursery"
        ]
        if matchesAnyKeyword(lowercased, keywords: familyKeywords) {
            return .babyFamily
        }

        // Default to custom for everything else
        return .custom
    }

    // MARK: - Private Helpers

    /// Check if the input matches any keyword using word boundary matching.
    /// Multi-word keywords use substring matching; single-word keywords require word boundaries.
    private static func matchesAnyKeyword(_ input: String, keywords: [String]) -> Bool {
        for keyword in keywords {
            if keyword.contains(" ") {
                // Multi-word: substring match is fine
                if input.contains(keyword) {
                    return true
                }
            } else {
                // Single-word: require word boundaries
                let pattern = "\\b\(NSRegularExpression.escapedPattern(for: keyword))\\b"
                if input.range(of: pattern, options: .regularExpression) != nil {
                    return true
                }
            }
        }
        return false
    }
}
