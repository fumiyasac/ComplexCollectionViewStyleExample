# [ING] - 新しいUICollectionViewとCombineを試す

iOS13から新しく追加されたUICollectionViewCompositionalLayoutとCombineを利用した複雑な画面構造を持つ画面のUI実装サンプルになります。

### 1. このサンプルについて

__【サンプル画面のデザイン】__

![サンプル図その1](https://github.com/fumiyasac/ComplexCollectionViewStyleExample/blob/master/images/sample_thumbnail1.jpg)

![サンプル図その2](https://github.com/fumiyasac/ComplexCollectionViewStyleExample/blob/master/images/sample_thumbnail2.jpg)

__【解説資料のメモ】__

全体的な流れとポイントとなりうる点に関してまとめたメモです。

![設計メモ](https://github.com/fumiyasac/ComplexCollectionViewStyleExample/blob/master/images/idea_note.jpg)

※ 登壇の際にまとめた資料は下記になります。

+ [試して感覚を掴んでみるUICollectionViewCompositionalLayout & Combine](https://www.slideshare.net/fumiyasakai37/uicollectionviewcompositionallayout-combine)

### 2. 事前準備と検証用Mockサーバーについて

本サンプルにおいてAPI通信を利用してデータの取得を行う機構を用意するにあたり、ローカル環境下でのAPI通信用のモックサーバー構築に[json-server](https://github.com/typicode/json-server)を利用しました。node.jsを利用した経験があるならば、すぐに導入できるかと思います。具体的な使い方は[こちら](https://blog.eleven-labs.com/en/json-server/)を参照して頂ければと思います。

利用する際には下記のような手順でお願いします。

__必要なパッケージのインストール:__

```
$ cd mock_server
$ npm install
```

__API通信用Mockサーバー起動:__

```
$ node index.js
```

1. 実機検証はできません。
2. 事前にnode.jsのインストールが必要になります。

### 3. UICollectionViewCompositionalLayoutで実現するレイアウト実装

UICollectionViewCompositionalLayoutを利用する際には下記のように、レイアウトの構成要素の関係性がある点がポイントになります。セクション毎の複雑なレイアウトの構築の構築が従来の実装よりも柔軟できることが大きな特徴かと思います。

+ [Move your cells left to right, up and down on iOS 13 — Part 1](https://medium.com/shopback-engineering/move-your-cells-left-to-right-up-and-down-on-ios-13-part-1-1a5e010f48f9)
+ [Move your cells left to right, up and down on iOS 13 — Part 2](https://medium.com/shopback-engineering/move-your-cells-left-to-right-up-and-down-on-ios-13-part-2-fbc430802227)

__Instagramのフィード画面のような画面を構築する場合:__

![レイアウト例その1](https://github.com/fumiyasac/ComplexCollectionViewStyleExample/blob/master/images/layout_dynamic_height.png)

__Instagramの写真一覧画面のような画面を構築する場合:__

![レイアウト例その2](https://github.com/fumiyasac/ComplexCollectionViewStyleExample/blob/master/images/layout_mosaic_layout.png)

### 4. Kickstarter-iOSのViewModelに似たInput/Outputを明示的に分割した実装

本サンプルにおけるAPIリクエストからデータを反映させる部分については基本的に「Combine + MVVM』の構成で実装をしています。※RxSwiftで実装する場合を考えてみるとイメージがしやすいのではないかと思います。

![アーキテクチャ概要図](https://github.com/fumiyasac/ComplexCollectionViewStyleExample/blob/master/images/architecture_introduction.png)

またViewControllerからのViewModelへのアクセス時に入力(Input)・出力(Output)をわかりやすくする意図も込めて「Kickstarter-iOS」で採用しているViewModelの構成に近しい形としています。

+ [Introducing ViewModel Inputs/Outputs: a modern approach to MVVM architecture](https://tech.mercari.com/entry/2019/06/12/120000)
+ [Kickstarter-iOSのViewModelの作り方がウマかった](https://qiita.com/muukii/items/045b12405f7acff1a9fd)

__本サンプルにおけるViewModelの実装例:__

![アーキテクチャViewModel](https://github.com/fumiyasac/ComplexCollectionViewStyleExample/blob/master/images/architecture_viewmodel.png)

__本サンプルにおけるViewController(データ反映反映)の実装例:__

![アーキテクチャViewModel](https://github.com/fumiyasac/ComplexCollectionViewStyleExample/blob/master/images/architecture_viewcontroller.png)
