// 参考: json-serverに関するもの
// https://blog.eleven-labs.com/en/json-server

// Mock用のJSONレスポンスサーバーの初期化設定
const jsonServer = require('json-server');
const server = jsonServer.create();

// Database構築用のJSONファイル
const router = jsonServer.router('datasource/db.json');

// 各種設定用
const middlewares = jsonServer.defaults();
const rewrite_rules = jsonServer.rewriter({
    "/api/mock/v1/gourmet/articles" : "/get_articles",
    "/api/mock/v1/gourmet/keywords" : "/get_keywords",
    "/api/mock/v1/gourmet/recommend" : "/get_recommend_list",
});

// リクエストのルールを設定する
server.use(rewrite_rules);

// ミドルウェアを設定する (※コンソール出力するロガーやキャッシュの設定等)
server.use(middlewares);

// 受信したリクエストにおいてGET送信時のみ許可する
server.use(function (req, res, next) {
    if (req.method === 'GET') {
        next();
    }
});

// ルーティングを設定する
server.use(router);

// サーバをポート3000で起動する
server.listen(3000, () => {
    console.log('JSON Server is running');
});
