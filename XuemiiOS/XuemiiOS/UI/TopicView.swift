//
//  TopicView.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 30/5/24.
//

import SwiftUI

enum Topic: Int, Identifiable, Codable, CaseIterable {
    case one = 1, two = 2, three = 3, eoy = 4
    
    var id: UUID {
        switch self {
        case .one, .two, .three, .eoy:
            return UUID()
        }
    }
    
    func string(level: SecondaryNumber, chapter: Chapter) -> String {
        switch level {
        case .one:
            switch chapter {
            case .one:
                switch self {
                case .one:
                    return "我的新同学"
                case .two:
                    return "一个蛋两个蛋三个蛋"
                case .three:
                    return "张老师“审案”"
                case .eoy:
                    return "年终考试"
                }
            case .two:
                switch self {
                case .one:
                    return "世界各地的新年风俗"
                case .two:
                    return "团圆饭"
                case .three:
                    return "幸运饺子"
                case .eoy:
                    return "年终考试"
                }
            case .three:
                switch self {
                case .one:
                    return "走街串巷逛狮城"
                case .two:
                    return "魅力四射 星耀樟宜"
                case .three:
                    return "国家美术馆探秘"
                case .eoy:
                    return "年终考试"
                }
            case .four:
                switch self {
                case .one:
                    return "培养好习惯"
                case .two:
                    return "迟到"
                case .three:
                    return "差不多先生"
                case .eoy:
                    return "年终考试"
                }
            case .five:
                switch self {
                case .one:
                    return "我是创新王"
                case .two:
                    return "海底牧场游记"
                case .three:
                    return "难忘的建筑之旅"
                case .eoy:
                    return "年终考试"
                }
            case .six:
                switch self {
                case .one:
                    return "我们的无名英雄"
                case .two:
                    return "我为狮城做贡献——走访地铁维修人员"
                case .three:
                    return "小人物的心声“一人一首新谣”专题系列报道"
                case .eoy:
                    return "年终考试"
                }
            case .eoy: return ""
            }
        case .two:
            switch chapter {
            case .one:
                switch self {
                case .one:
                    return "我想对您说"
                case .two:
                    return "把爱说出来"
                case .three:
                    return "放风筝"
                case .eoy:
                    return "年终考试"
                }
            case .two:
                switch self {
                case .one:
                    return "助养野生动物"
                case .two:
                    return "猫"
                case .three:
                    return "山中奇遇"
                case .eoy:
                    return "年终考试"
                }
            case .three:
                switch self {
                case .one:
                    return "水都去哪儿了？"
                case .two:
                    return "人类最糟糕的发明"
                case .three:
                    return "手机被丢弃之后"
                case .eoy:
                    return "年终考试"
                }
            case .four:
                switch self {
                case .one:
                    return "心情手账"
                case .two:
                    return "恐怖事件"
                case .three:
                    return "最美的姿势"
                case .eoy:
                    return "年终考试"
                }
            case .five:
                switch self {
                case .one:
                    return "组屋：新加坡一道美丽的风景线"
                case .two:
                    return "雨树"
                case .three:
                    return "如果走散了"
                case .eoy:
                    return "年终考试"
                }
            case .six:
                switch self {
                case .one:
                    return "新加坡与世界的联系"
                case .two:
                    return "多元而开放的新加坡"
                case .three:
                    return "别上假信息的当"
                case .eoy:
                    return "年终考试"
                }
            case .eoy: return ""
            }
        case .three:
            switch chapter {
            case .one:
                switch self {
                case .one:
                    return "如何建立良好的人际关系"
                case .two:
                    return "谢谢你的沉默"
                case .three:
                    return "饼干罐的秘密"
                case .eoy:
                    return "年终考试"
                }
            case .two:
                switch self {
                case .one:
                    return "健康生活系列广告"
                case .two:
                    return "吃茶喝茶品茶"
                case .three:
                    return "街舞"
                case .eoy:
                    return "年终考试"
                }
            case .three:
                switch self {
                case .one:
                    return "我的社区节"
                case .two:
                    return "远亲不如近邻"
                case .three:
                    return "社区网络群组让邻里感情更深厚"
                case .eoy:
                    return "年终考试"
                }
            case .four:
                switch self {
                case .one:
                    return "成为演说高手"
                case .two:
                    return "沟通面面观"
                case .three:
                    return "社交媒体拉近你我他"
                case .eoy:
                    return "年终考试"
                }
            case .five:
                switch self {
                case .one:
                    return "你在学什么"
                case .two:
                    return "学然后知不足"
                case .three:
                    return "终身学习"
                case .eoy:
                    return "年终考试"
                }
            case .six:
                switch self {
                case .one:
                    return "真善美摄影展"
                case .two:
                    return "父亲和鱼"
                case .three:
                    return "唯一的听众"
                case .eoy:
                    return "年终考试"
                }
            case .eoy: return ""
            }
        case .four:
            switch chapter {
            case .one:
                switch self {
                case .one:
                    return "关怀满人间——慈善团体简介"
                case .two:
                    return "坦然走过乞丐"
                case .three:
                    return "给善良插上翅膀"
                case .eoy:
                    return "年终考试"
                }
            case .two:
                switch self {
                case .one:
                    return "戏剧中的人生百态"
                case .two:
                    return "林黛玉进贾府"
                case .three:
                    return "三顾茅庐"
                case .eoy:
                    return "年终考试"
                }
            case .three:
                switch self {
                case .one:
                    return "被破坏的生态平衡"
                case .two:
                    return "对抗气候变化的超级英雄——红树林"
                case .three:
                    return "狼鹿效应"
                case .eoy:
                    return "年终考试"
                }
            case .four:
                switch self {
                case .one:
                    return "亚细安知多少"
                case .two:
                    return "自知之明"
                case .three:
                    return "小国更需要合作"
                case .eoy:
                    return "年终考试"
                }
            case .five:
                switch self {
                case .one:
                    return "追逐梦想——为梦想加油点赞"
                case .two:
                    return "江城子·密州出猎"
                case .three:
                    return "在山的那边"
                case .eoy:
                    return "年终考试"
                }
            case .six: return ""
            case .eoy: return ""
            }
        }
    }
}

struct TopicView: View {
    var level: SecondaryNumber
    var chapter: Chapter
    
    @State private var showingSheet = false
    @State private var showingFlashcards = false
    @State private var showingMCQ = false
    @State private var showingMemoryCards = false
    @State private var topicSelected: Topic?
    
    var body: some View {
        ScrollView {
            Text("中 \(level.string)")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .padding()
                .frame(height: 80)
                .frame(maxWidth: .infinity)
                .foregroundStyle(.white)
                .background(.customblue)
                .mask(RoundedRectangle(cornerRadius: 16))
                .padding([.horizontal, .bottom])
            
            ForEach(Topic.allCases, id: \.self) { topic in
                if topic != .eoy {
                    Button {
                        showingSheet = true
                        topicSelected = topic
                    } label: {
                        VStack(alignment: .leading) {
                            Text(topic.string(level: level, chapter: chapter))
                                .font(.title)
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                                .padding()
                                .frame(height: 65)
                                .frame(maxWidth: .infinity)
                                .foregroundStyle(.black)
                                .background(.customgray)
                                .mask(RoundedRectangle(cornerRadius: 16))
                                .padding(.horizontal)
                        }
                    }
                    .navigationTitle(chapter.string)
                    .sheet(isPresented: $showingSheet) {
                        NavigationStack {
                            VStack {
                                Button {
                                    showingSheet = false
                                    showingMCQ.toggle()
                                } label: {
                                    Text("MCQ")
                                        .font(.title)
                                        .padding()
                                        .frame(height: 65)
                                        .frame(maxWidth: .infinity)
                                        .foregroundStyle(.black)
                                        .background(.customgray)
                                        .mask(RoundedRectangle(cornerRadius: 16))
                                        .padding(.horizontal)
                                }
                                
                                Button {
                                    showingSheet = false
                                    showingFlashcards.toggle()
                                } label: {
                                    Text("Flashcards")
                                        .font(.title)
                                        .padding()
                                        .frame(height: 65)
                                        .frame(maxWidth: .infinity)
                                        .foregroundStyle(.black)
                                        .background(.customgray)
                                        .mask(RoundedRectangle(cornerRadius: 16))
                                        .padding(.horizontal)
                                }
                                
                                Button {
                                    showingSheet = false
                                    showingMemoryCards.toggle()
                                } label: {
                                    Text("Memory Cards")
                                        .font(.title)
                                        .padding()
                                        .frame(height: 65)
                                        .frame(maxWidth: .infinity)
                                        .foregroundStyle(.black)
                                        .background(.customgray)
                                        .mask(RoundedRectangle(cornerRadius: 16))
                                        .padding(.horizontal)
                                }
                            }
                            .navigationTitle("习题")
                        }
                        .presentationDetents([.medium])
                        .padding(.top, -30)
                    }
                }
            }
        }
        .navigationDestination(isPresented: $showingFlashcards) {
            if let topicSelected = topicSelected {
                FlashcardView(
                    vocabularies: loadVocabulariesFromJSON(
                        fileName: "中\(level.string)",
                        chapter: chapter.string,
                        topic: topicSelected.string(level: level, chapter: chapter)
                    ),
                    level: level,
                    chapter: chapter,
                    topic: topicSelected
                )
            }
        }
        .navigationDestination(isPresented: $showingMCQ) {
            if let topicSelected = topicSelected {
                MCQView(
                    vocabularies: loadVocabulariesFromJSON(
                        fileName: "中\(level.string)",
                        chapter: chapter.string,
                        topic: topicSelected.string(level: level, chapter: chapter)
                    ),
                    level: level,              // ✅ enum SecondaryNumber
                    chapter: chapter,          // ✅ enum Chapter
                    topic: topicSelected       // ✅ enum Topic
                )
            }
        }
        .navigationDestination(isPresented: $showingMemoryCards) {
            if let topicSelected = topicSelected {
                MemoryCardView(
                    vocabularies: loadVocabulariesFromJSON(
                        fileName: "中\(level.string)",
                        chapter: chapter.string,
                        topic: topicSelected.string(level: level, chapter: chapter)
                    ),
                    level: level,
                    chapter: chapter,
                    topic: topicSelected
                )
            }
        }
    }
}


#Preview {
    TopicView(level: .one, chapter: .one)
}
