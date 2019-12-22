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
＜実装を試していく過程で参考にした資料集＞
● Move your cells left to right, up and down on iOS 13
https://medium.com/shopback-engineering/move-your-cells-left-to-right-up-and-down-on-ios-13-part-1-1a5e010f48f9
https://medium.com/shopback-engineering/move-your-cells-left-to-right-up-and-down-on-ios-13-part-2-fbc430802227

----------
Point2: レイアウトの組み方を知る
----------
Step1. 全体のLayoutの中にSectionが配置され、さらにその中に複数のItemを内包するGroupがある
● Layout ⊇ Section ⊇ Group ⊇ Item という関係を持つ（全体のLayoutの中にSectionが配置され、さらにその中に複数のItemを内包するGroupがある）
→ 小さな粒度の「Itemのサイズ設定 → Groupのサイズ設定 → Sectionのインスタンスを作る」という順番で組み立てていくことがポイント

Step2. NSCollectionLayoutSizeの基本
(1) .fractionalWidth(割合) & .fractionalHeight(割合) → Groupからの割合から算出した値
(2) .absolute(値) → 決め打ちの値
(3) .estimate(値) → 最初は値のままだが設定した値より大きい場合には可変する
*/

// MARK: - Enum

enum MainSection: Int, CaseIterable {
    case FeaturedBanners
    case FeaturedInterviews
    case RecentKeywords
    case NewArrivalArticles
    case RegularArticles
}

final class MainViewController: UIViewController {

    // MARK: - Variables

    private var cancellables: [AnyCancellable] = []

    // MEMO: API経由の非同期通信からデータを取得するためのViewModel
    private let viewModel: MainViewModel = MainViewModel(api: APIRequestManager.shared)

    // MEMO: UICollectionViewを差分更新するためのNSDiffableDataSourceSnapshot（※悩ましい: AnyHashableではなくもっと厳密に制限したい）
    private var snapshot: NSDiffableDataSourceSnapshot<MainSection, AnyHashable>!

    // MEMO: UICollectionViewを組み立てるためのDataSource（※悩ましい: AnyHashableの部分を型で縛りたい）
    private var dataSource: UICollectionViewDiffableDataSource<MainSection, AnyHashable>! = nil

    // MEMO: UICollectionViewCompositionalLayoutの設定（※Sectionごとに読み込ませて利用する）
    private lazy var compositionalLayout: UICollectionViewCompositionalLayout = {
        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in

            switch sectionIndex {

            // MainSection: 0 (FeaturedBanners)
            case MainSection.FeaturedBanners.rawValue:
                return self?.createFeaturedBannersLayout()

            // MainSection: 1 (FeaturedInterviews)
            case MainSection.FeaturedInterviews.rawValue:
                return self?.createFeaturedInterviewsLayout()

            // MainSection: 2 (RecentKeywords)
            case MainSection.RecentKeywords.rawValue:
                return self?.createRecentKeywordsLayout()

            // MainSection: 3 (NewArrivalArticles)
            case MainSection.NewArrivalArticles.rawValue:
                return self?.createNewArrivalArticles()

            // MainSection: 4 (RegularArticles)
            case MainSection.RegularArticles.rawValue:
                return self?.createRegularArticles()

            default:
                fatalError()
            }
        }
        return layout
    }()
    
    // MARK: - @IBOutlet

    @IBOutlet private weak var collectionView: UICollectionView!

    // MARK: - deinit

    deinit {
        cancellables.forEach { $0.cancel() }
    }

    // MARK: - Override

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
        bindToMainViewModelOutputs()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // MEMO: ViewModelのInputsを経由したAPIでのデータ取得処理を実行する
        viewModel.inputs.fetchFeaturedBannersTrigger.send()
        viewModel.inputs.fetchFeaturedInterviewsTrigger.send()
        viewModel.inputs.fetchKeywordsTrigger.send()
        viewModel.inputs.fetchNewArrivalsTrigger.send()
        viewModel.inputs.fetchArticlesTrigger.send()
    }

    // MARK: - Private Function (for UICollectionView Setup)

    private func setupCollectionView() {

        // MEMO: このレイアウトで利用するセル要素・Header・Footerの登録

        // MainSection: 0 (FeaturedBanner)
        collectionView.registerCustomCell(FeaturedCollectionViewCell.self)

        // MainSection: 1 (FeaturedInterview)
        collectionView.registerCustomCell(FeaturedInterviewCollectionViewCell.self)

        // MainSection: 2 (RecentKeyword)
        collectionView.registerCustomCell(KeywordCollectionViewCell.self)
        collectionView.registerCustomReusableHeaderView(KeywordCollectionHeaderView.self)
        collectionView.registerCustomReusableFooterView(KeywordCollectionFooterView.self)

        // MainSection: 3 (NewArrivalArticle)
        collectionView.registerCustomCell(NewArrivalCollectionViewCell.self)
        collectionView.registerCustomCell(PhotoCollectionViewCell.self)
        collectionView.registerCustomReusableHeaderView(NewArrivalCollectionHeaderView.self)

        // MainSection: 4 (RegularArticle)
        collectionView.registerCustomCell(ArticleCollectionViewCell.self)
        collectionView.registerCustomReusableHeaderView(ArticleCollectionHeaderView.self)

        // MEMO: UICollectionViewDelegateについては従来通り
        collectionView.delegate = self

        // MEMO: UICollectionViewCompositionalLayoutを利用してレイアウトを組み立てる
        collectionView.collectionViewLayout = compositionalLayout

        // MEMO: DataSourceはUICollectionViewDiffableDataSourceを利用してUICollectionViewCellを継承したクラスを組み立てる
        dataSource = UICollectionViewDiffableDataSource<MainSection, AnyHashable>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, model: AnyHashable) -> UICollectionViewCell? in
            
            switch model {

            // MainSection: 0 (FeaturedBanner)
            case let model as FeaturedBanner:

                let cell = collectionView.dequeueReusableCustomCell(with: FeaturedCollectionViewCell.self, indexPath: indexPath)
                cell.setCell(model)
                return cell

            // MainSection: 1 (FeaturedInterview)
            case let model as FeaturedInterview:

                let cell = collectionView.dequeueReusableCustomCell(with: FeaturedInterviewCollectionViewCell.self, indexPath: indexPath)
                cell.setCell(model)
                return cell

            // MainSection: 2 (RecentKeyword)
            case let model as Keyword:

                let cell = collectionView.dequeueReusableCustomCell(with: KeywordCollectionViewCell.self, indexPath: indexPath)
                cell.setCell(model)
                return cell

            // MainSection: 3 (NewArrivalArticle)
            case let model as NewArrival:

                // MEMO: 3で割って1余るインデックス値の場合は大きなサイズのセルを適用する
                if model.id % 3 == 1 {
                    let cell = collectionView.dequeueReusableCustomCell(with: NewArrivalCollectionViewCell.self, indexPath: indexPath)
                    cell.setCell(model, index: indexPath.row + 1)
                    return cell
                } else {
                    let cell = collectionView.dequeueReusableCustomCell(with: PhotoCollectionViewCell.self, indexPath: indexPath)
                    cell.setCell(model, index: indexPath.row + 1)
                    return cell
                }

            // MainSection: 4 (RegularArticle)
            case let model as Article:

                let cell = collectionView.dequeueReusableCustomCell(with: ArticleCollectionViewCell.self, indexPath: indexPath)
                cell.setCell(model)
                return cell

            default:
                return nil
            }
        }

        // MEMO: Header・Footerの表記についてもUICollectionViewDiffableDataSourceを利用して組み立てる
        dataSource.supplementaryViewProvider = { (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in

            switch indexPath.section {

            // MainSection: 2 (RecentKeyword)
            case MainSection.RecentKeywords.rawValue:
                if kind == UICollectionView.elementKindSectionHeader {
                    let header = collectionView.dequeueReusableCustomHeaderView(with: KeywordCollectionHeaderView.self, indexPath: indexPath)
                    header.setHeader(
                        title: "最近の「キーワード」をチェック",
                        description: "テレビ番組で人気のお店や特別な日に使える情報をたくさん掲載しております。気になるキーワードはあるけれども「あのお店なんだっけ？」というのが具体的に思い出せない場面が結構あると思います。最新情報に早めにキャッチアップしたい方におすすめです！"
                    )
                    return header
                }
                if kind == UICollectionView.elementKindSectionFooter {
                    let footer = collectionView.dequeueReusableCustomFooterView(with: KeywordCollectionFooterView.self, indexPath: indexPath)
                    return footer
                }

            // MainSection: 3 (NewArrivalArticle)
            case MainSection.NewArrivalArticles.rawValue:
                if kind == UICollectionView.elementKindSectionHeader {
                    let header = collectionView.dequeueReusableCustomHeaderView(with: NewArrivalCollectionHeaderView.self, indexPath: indexPath)
                    header.setHeader(
                        title: "新着メニューの紹介",
                        description: "アプリでご紹介しているお店の新着メニューを紹介しています。新しいお店の発掘やさらなる行きつけのお店の魅力を見つけられるかもしれません。"
                    )
                    return header
                }

            // MainSection: 4 (RegularArticle)
            case MainSection.RegularArticles.rawValue:
                if kind == UICollectionView.elementKindSectionHeader {
                    let header = collectionView.dequeueReusableCustomHeaderView(with: ArticleCollectionHeaderView.self, indexPath: indexPath)
                    header.setHeader(
                        title: "おすすめ記事一覧",
                        description: "よく行くお店からこちらで厳選してみました。というつもりです…。でも結構美味しそうなのではないかと思いますよので是非ともご堪能してみてはいかがでしょうか？"
                    )
                    return header
                }

            default:
                break
            }
            return nil
        }

        // MEMO: NSDiffableDataSourceSnapshotの初期設定
        snapshot = NSDiffableDataSourceSnapshot<MainSection, AnyHashable>()
        snapshot.appendSections(MainSection.allCases)
        for mainSection in MainSection.allCases {
            snapshot.appendItems([], toSection: mainSection)
        }
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    private func bindToMainViewModelOutputs() {

        // 1. ViewModelのOutputsを経由した特集バナーデータの取得とNSDiffableDataSourceSnapshotの入れ替え処理
        viewModel.outputs.featuredBanners
            .subscribe(on: RunLoop.main)
            .sink(
                receiveValue: { [weak self] featuredBanners in
                    guard let self = self else { return }
                    self.snapshot.appendItems(featuredBanners, toSection: .FeaturedBanners)
                    self.dataSource.apply(self.snapshot, animatingDifferences: false)
                }
            )
            .store(in: &cancellables)

        // 2. ViewModelのOutputsを経由した特集インタビューデータの取得とNSDiffableDataSourceSnapshotの入れ替え処理
        viewModel.outputs.featuredInterviews
            .subscribe(on: RunLoop.main)
            .sink(
                receiveValue: { [weak self] featuredInterviews in
                    guard let self = self else { return }
                    self.snapshot.appendItems(featuredInterviews, toSection: .FeaturedInterviews)
                    self.dataSource.apply(self.snapshot, animatingDifferences: false)
                }
            )
            .store(in: &cancellables)

        // 3. ViewModelのOutputsを経由したキーワードデータの取得とNSDiffableDataSourceSnapshotの入れ替え処理
        viewModel.outputs.keywords
            .subscribe(on: RunLoop.main)
            .sink(
                receiveValue: { [weak self] keywords in
                    guard let self = self else { return }
                    self.snapshot.appendItems(keywords, toSection: .RecentKeywords)
                    self.dataSource.apply(self.snapshot, animatingDifferences: false)
                }
            )
            .store(in: &cancellables)

        // 4. ViewModelのOutputsを経由した新着データの取得とNSDiffableDataSourceSnapshotの入れ替え処理
        viewModel.outputs.newArrivals
            .subscribe(on: RunLoop.main)
            .sink(
                receiveValue: { [weak self] newArrivals in
                    guard let self = self else { return }
                    self.snapshot.appendItems(newArrivals, toSection: .NewArrivalArticles)
                    self.dataSource.apply(self.snapshot, animatingDifferences: false)
                }
            )
            .store(in: &cancellables)

        // 5. ViewModelのOutputsを経由した記事データの取得とNSDiffableDataSourceSnapshotの入れ替え処理
        viewModel.outputs.articles
            .subscribe(on: RunLoop.main)
            .sink(
                receiveValue: { [weak self] articles in
                    guard let self = self else { return }
                    self.snapshot.appendItems(articles, toSection: .RegularArticles)
                    self.dataSource.apply(self.snapshot, animatingDifferences: false)
                }
            )
            .store(in: &cancellables)
    }

    // MARK: - Private Function (for UICollectionViewCompositionalLayout Setup)

    private func createFeaturedBannersLayout() -> NSCollectionLayoutSection {

        // 1. Itemのサイズ設定
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .zero

        // 2. Groupのサイズ設定
        // MEMO: 1列に表示するカラム数を1として設定し、itemのサイズがgroupのサイズで決定する形にしている
        let groupHeight = UIScreen.main.bounds.width * (3 / 8)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(groupHeight))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 1)
        group.contentInsets = .zero

        // 3. Sectionのサイズ設定
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0)
        // MEMO: スクロール終了時に水平方向のスクロールが可能で中心位置で止まる
        section.orthogonalScrollingBehavior = .groupPagingCentered
        return section
    }

    private func createFeaturedInterviewsLayout() -> NSCollectionLayoutSection {

        // MEMO: 該当のセルを基準にした高さの予測値を設定する
        let estimatedHeight = UIScreen.main.bounds.width + 180.0

        // 1. Itemのサイズ設定
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(estimatedHeight))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .zero

        // 2. Groupのサイズ設定
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(estimatedHeight))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        group.contentInsets = .zero

        // 3. Sectionのサイズ設定
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0)

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
        let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(28.0))
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

        // MEMO: 該当のセルを基準にした高さを設定する
        let absoluteHeight = UIScreen.main.bounds.width * 0.5 + 90.0

        // 1. Itemのサイズ設定
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0.5, leading: 0.5, bottom: 0.5, trailing: 0.5)

        // 2. Groupのサイズ設定
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(absoluteHeight))
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

extension MainViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        // MEMO: 該当のセクションとIndexPathからNSDiffableDataSourceSnapshot内の該当する値を取得する
        if let targetSection = MainSection(rawValue: indexPath.section) {
            let targetSnapshot = snapshot.itemIdentifiers(inSection: targetSection)
            print("Section: ", targetSection)
            print("IndexPath.row: ", indexPath.row)
            print("Model: ", targetSnapshot[indexPath.row])
        }
    }
}

// MARK: - UIScrollViewDelegate

extension MainViewController: UIScrollViewDelegate {

    // MEMO: NSCollectionLayoutSectionのScroll(section.orthogonalScrollingBehavior)ではUIScrollViewDelegateは呼ばれない
    func scrollViewDidScroll(_ scrollView: UIScrollView) {}
}
