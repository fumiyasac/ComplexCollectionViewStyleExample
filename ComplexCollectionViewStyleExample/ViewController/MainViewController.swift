//
//  MainViewController.swift
//  ComplexCollectionViewStyleExample
//
//  Created by 酒井文也 on 2019/10/31.
//  Copyright © 2019 酒井文也. All rights reserved.
//

import UIKit
import Combine

// MARK: - Description of Implementation

/*
----------
Point1: UICollectionViewCompositionalLayoutを知る
----------
Step1. 「知識ベースとイメージで良いのでどんなものかを知る」ことから始める
＜基本を理解する上で参考にした資料集＞
● 時代の変化に応じて進化するCollectionView ~Compositional LayoutsとDiffable Data Sources~
https://qiita.com/shiz/items/a6032543a237bf2e1d19
●
＜実装を試していく過程で参考にした資料集＞

----------
Point2: レイアウトの組み方を知る
----------
Step1. 全体のLayoutの中にSectionが配置され、さらにその中に複数のItemを内包するGroupがある
● Layout ⊇ Section ⊇ Group ⊇ Item という関係を持つ（全体のLayoutの中にSectionが配置され、さらにその中に複数のItemを内包するGroupがある）
→ 小さな粒度の「Itemのサイズ設定 → Groupのサイズ設定 → Sectionのインスタンスを作る」という順番で組み立てていくことがポイント

Step2. NSCollectionLayoutSizeの基本
(1) .fractionalWidth(割合) & .fractionalHeight(割合) → Groupからの割合から算出した値
(2) .absolute(値) → 決め打ちの値
(3) .estimate(値) → 最初は値のままだが可変する（※実際に動かしてみたが怪しい...???）

 

*/

// MARK: - Enum

enum MainSection: CaseIterable {
    case FeaturedArticles
    case RecentKeywords
    case NewArrivalArticles
    case RegularArticles

    func getSectionValue() -> Int {
        switch self {
        case .FeaturedArticles:
            return 0
        case .RecentKeywords:
            return 1
        case .NewArrivalArticles:
            return 2
        case .RegularArticles:
            return 3
        }
    }
}

final class MainViewController: UIViewController {

    // MARK: - Variables

    // MEMO: API経由の非同期通信からデータを取得するためのViewModel
    private let viewModel: MainViewModel = MainViewModel()

    // MEMO: UICollectionViewを組み立てるためのDataSource（※悩ましい: AnyHashableの部分を型で縛りたい）
    private var dataSource: UICollectionViewDiffableDataSource<MainSection, AnyHashable>! = nil

    // MEMO: UICollectionViewCompositionalLayoutの設定（※Sectionごとに読み込ませて利用する）
    private lazy var compositionalLayout: UICollectionViewCompositionalLayout = {
        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in

            switch sectionIndex {
            case MainSection.FeaturedArticles.getSectionValue():
                return self?.createFeaturedArticlesLayout()
            case MainSection.RecentKeywords.getSectionValue():
                return self?.createRecentKeywordsLayout()
            case MainSection.NewArrivalArticles.getSectionValue():
                return self?.createNewArrivalArticles()
            case MainSection.RegularArticles.getSectionValue():
                return self?.createRegularArticles()
            default:
                fatalError()
            }
        }
        return layout
    }()
    
    // MARK: - @IBOutlet

    @IBOutlet private weak var collectionView: UICollectionView!
    
    // MARK: - Override

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
    }

    // MARK: - Private Function (for UICollectionView Setup)

    private func setupCollectionView() {

        // MEMO: このレイアウトで利用するセル要素・Header・Footerの登録
        collectionView.registerCustomCell(KeywordCollectionViewCell.self)
        collectionView.registerCustomReusableHeaderView(KeywordCollectionHeaderView.self)
        collectionView.registerCustomReusableFooterView(KeywordCollectionFooterView.self)
        collectionView.registerCustomCell(FeaturedCollectionViewCell.self)
        collectionView.registerCustomCell(NewArrivalCollectionViewCell.self)
        collectionView.registerCustomReusableHeaderView(NewArrivalCollectionHeaderView.self)
        collectionView.registerCustomCell(PhotoCollectionViewCell.self)
        collectionView.registerCustomCell(ArticleCollectionViewCell.self)
        collectionView.registerCustomReusableHeaderView(ArticleCollectionHeaderView.self)

        // MEMO: UICollectionViewDelegateについては従来通り
        collectionView.delegate = self

        // MEMO: UICollectionViewCompositionalLayoutを利用してレイアウトを組み立てる
        collectionView.collectionViewLayout = compositionalLayout

        // MEMO: DataSourceはUICollectionViewDiffableDataSourceを利用してUICollectionViewCellを継承したクラスを組み立てる
        dataSource = UICollectionViewDiffableDataSource<MainSection, AnyHashable>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, model: AnyHashable) -> UICollectionViewCell? in
            
            switch model {
            case let model as FeaturedBanner:
                let cell = collectionView.dequeueReusableCustomCell(with: FeaturedCollectionViewCell.self, indexPath: indexPath)
                cell.titleLabel.text = model.title
                cell.dateStringLabel.text = model.dateString
                return cell
            case let model as Keyword:
                let cell = collectionView.dequeueReusableCustomCell(with: KeywordCollectionViewCell.self, indexPath: indexPath)
                cell.titleLabel.text = model.keyword
                return cell
            case let model as NewArrival:
                if model.id % 3 == 1 {
                    let cell = collectionView.dequeueReusableCustomCell(with: NewArrivalCollectionViewCell.self, indexPath: indexPath)
                    cell.indexLabel.text = String(model.id)
                    return cell
                } else {
                    let cell = collectionView.dequeueReusableCustomCell(with: PhotoCollectionViewCell.self, indexPath: indexPath)
                    cell.indexLabel.text = String(model.id)
                    return cell
                }
            case let model as Article:
                let cell = collectionView.dequeueReusableCustomCell(with: ArticleCollectionViewCell.self, indexPath: indexPath)
                return cell
            default:
                return nil
            }
        }

        // MEMO: Header・Footerの表記についてもUICollectionViewDiffableDataSourceを利用して組み立てる
        dataSource.supplementaryViewProvider = { (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in

            switch indexPath.section {
            case MainSection.RecentKeywords.getSectionValue():
                if kind == UICollectionView.elementKindSectionHeader {
                    let header = collectionView.dequeueReusableCustomHeaderView(with: KeywordCollectionHeaderView.self, indexPath: indexPath)
                    header.titleLabel.text = "最近の「キーワード」をチェック"
                    header.descriptionLabel.text = "テレビ番組で人気のお店や特別な日に使える情報をたくさん掲載しております。気になるキーワードはあるけれども「あのお店なんだっけ？」というのが具体的に思い出せない場面が結構あると思います。最新情報に早めにキャッチアップしたい方におすすめです！"
                    return header
                }
                if kind == UICollectionView.elementKindSectionFooter {
                    let footer = collectionView.dequeueReusableCustomFooterView(with: KeywordCollectionFooterView.self, indexPath: indexPath)
                    return footer
                }
            case MainSection.NewArrivalArticles.getSectionValue():
                if kind == UICollectionView.elementKindSectionHeader {
                    let header = collectionView.dequeueReusableCustomHeaderView(with: NewArrivalCollectionHeaderView.self, indexPath: indexPath)
                    header.titleLabel.text = "新着メニューの紹介"
                    header.descriptionLabel.text = "アプリでご紹介しているお店の新着メニューを紹介しています。新しいお店の発掘やさらなる行きつけのお店の魅力を見つけられるかもしれません。"
                    return header
                }
            case MainSection.RegularArticles.getSectionValue():
                if kind == UICollectionView.elementKindSectionHeader {
                    let header = collectionView.dequeueReusableCustomHeaderView(with: ArticleCollectionHeaderView.self, indexPath: indexPath)
                    header.titleLabel.text = "おすすめ記事一覧"
                    header.descriptionLabel.text = "よく行くお店からこちらで厳選してみました。というつもりです...。でも結構美味しそうなのではないかと思いますよので是非ともご堪能してみてはいかがでしょうか？"
                    return header
                }
            default:
                break
            }
            return nil
        }

        var snapshot = NSDiffableDataSourceSnapshot<MainSection, AnyHashable>()
        snapshot.appendSections(MainSection.allCases)

        let featuredBanners: [FeaturedBanner] = (0..<6).map {
            let id = $0 + 1
            return FeaturedBanner(id: id, title: "Feature Banner No.\(id)", dateString: "2019.99.99")
        }
        snapshot.appendItems(featuredBanners, toSection: .FeaturedArticles)

        let keywords: [Keyword] = (0..<20).map {
            let id = $0 + 1
            return Keyword(id: id, keyword: "Keyword Sample \(id)")
        }
        snapshot.appendItems(keywords, toSection: .RecentKeywords)

        let newArrival: [NewArrival] = (0..<12).map {
            let id = $0 + 1
            return NewArrival(id: id)
        }
        snapshot.appendItems(newArrival, toSection: .NewArrivalArticles)

        let article: [Article] = (0..<20).map {
            let id = $0 + 1
            return Article(id: id)
        }
        snapshot.appendItems(article, toSection: .RegularArticles)

        dataSource.apply(snapshot, animatingDifferences: false)
    }

    // MARK: - Private Function (for UICollectionViewCompositionalLayout Setup)

    private func createFeaturedArticlesLayout() -> NSCollectionLayoutSection {

        // 1. Itemのサイズ設定
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        // 2. Groupのサイズ設定
        // MEMO: 1列に表示するカラム数を1として設定し、itemのサイズがgroupのサイズで決定する形にしている
        let groupHeight = UIScreen.main.bounds.width * (3 / 8)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(groupHeight))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 1)
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

        // 3. Sectionのサイズ設定
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0)
        // MEMO: スクロール終了時に水平方向のスクロールが可能で中心位置で止まる
        section.orthogonalScrollingBehavior = .groupPagingCentered
        return section
    }

    private func createRecentKeywordsLayout() -> NSCollectionLayoutSection {

        // 1. Itemのサイズ設定
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 6)
        
        // 2. Groupのサイズ設定
        // MEMO: 1列に表示するカラム数を1として設定し、itemのサイズがgroupのサイズで決定する形にしている
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(160), heightDimension: .absolute(40))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 1)

        // 3. Sectionのサイズ設定
        let section = NSCollectionLayoutSection(group: group)
        // MEMO: HeaderとFooterのレイアウトを決定する
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(65.0))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(15.0))
        let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerSize, elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)
        section.boundarySupplementaryItems = [header, footer]
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 6, bottom: 16, trailing: 6)
        // MEMO: スクロール終了時に水平方向のスクロールが可能で速度が0になった位置で止まる
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary

        return section
    }

    private func createNewArrivalArticles() -> NSCollectionLayoutSection {

        // 1. Itemのサイズ設定
        // MEMO: 全体幅2/3の正方形を作るために左側の幅を.fractionalWidth(0.67)に決める
        let twoThirdItemSet = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.67), heightDimension: .fractionalHeight(1.0)))
        twoThirdItemSet.contentInsets = NSDirectionalEdgeInsets(top: 0.5, leading: 0.5, bottom: 0.5, trailing: 0.5)
        // MEMO: 右側に全体幅1/3の正方形を2つ作るために高さを.fractionalHeight(0.5)に決める
        let oneThirdItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.5)))
        oneThirdItem.contentInsets = NSDirectionalEdgeInsets(top: 0.5, leading: 0.5, bottom: 0.5, trailing: 0.5)
        // MEMO: 1列に表示するカラム数を2として設定し、Group内のアイテムの幅を1/3の正方形とするためにGroup内の幅を.fractionalWidth(0.33)に決める
        let oneThirdItemSet = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.33), heightDimension: .fractionalHeight(1.0)), subitem: oneThirdItem, count: 2)

        // 2. Groupのサイズ設定
        // MEMO: leadingItem(左側へ表示するアイテム1つ)とtrailingGroup(右側へ表示するアイテム2個のグループ1個)を合わせる
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.33)), subitems: [twoThirdItemSet, oneThirdItemSet])

        // 3. Sectionのサイズ設定
        let section = NSCollectionLayoutSection(group: group)
        // MEMO: HeaderとFooterのレイアウトを決定する
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        section.boundarySupplementaryItems = [header]
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0)

        return section
    }

    private func createRegularArticles() -> NSCollectionLayoutSection {

        // 1. Itemのサイズ設定
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0.5, leading: 0.5, bottom: 0.5, trailing: 0.5)

        // 2. Groupのサイズ設定
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(UIScreen.main.bounds.width / 2 + 80.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)

        // 3. Sectionのサイズ設定
        let section = NSCollectionLayoutSection(group: group)
        // MEMO: HeaderとFooterのレイアウトを決定する
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(65.0))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        section.boundarySupplementaryItems = [header]

        return section
    }
}

// MARK: - UICollectionViewDelegate

extension MainViewController: UICollectionViewDelegate {}

// MARK: - UIScrollViewDelegate

extension MainViewController: UIScrollViewDelegate {}
