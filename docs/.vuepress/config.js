module.exports = {
  // 站点配置
  title: 'OPA 技术文档',
  description: 'Open Policy Agent - 全面技术分析与实践指南',
  base: '/OPA/',
  
  // 主题配置
  themeConfig: {
    // 导航栏
    nav: [
      { text: '首页', link: '/' },
      { text: '快速开始', link: '/QUICK_REFERENCE' },
      { text: 'FAQ', link: '/FAQ' },
      { text: '学习路径', link: '/LEARNING_PATH' },
      { text: '术语表', link: '/GLOSSARY' },
      { 
        text: '代码示例', 
        link: '/examples/',
        items: [
          { text: 'Hello World', link: '/examples/01-hello-world/' },
          { text: 'RBAC权限', link: '/examples/02-basic-rbac/' },
          { text: 'K8s准入', link: '/examples/03-kubernetes-admission/' },
          { text: '性能优化', link: '/examples/04-performance-optimization/' }
        ]
      },
      { text: 'GitHub', link: 'https://github.com/YOUR_USERNAME/OPA' }
    ],
    
    // 侧边栏
    sidebar: {
      '/': [
        {
          title: '📖 总览',
          collapsable: false,
          children: [
            '',
            '00-总览与索引'
          ]
        },
        {
          title: '🔧 技术规范',
          collapsable: true,
          children: [
            '01-技术规范/01.1-API规范',
            '01-技术规范/01.2-Bundle格式规范',
            '01-技术规范/01.3-WASM编译规范',
            '01-技术规范/01.4-性能基准与度量',
            '01-技术规范/01.5-安全合规标准'
          ]
        },
        {
          title: '📖 语言模型',
          collapsable: true,
          children: [
            '02-语言模型/02.1-Rego语法规范',
            '02-语言模型/02.2-类型系统',
            '02-语言模型/02.3-内置函数库',
            '02-语言模型/02.4-求值模型'
          ]
        },
        {
          title: '⚙️ 实现架构',
          collapsable: true,
          children: [
            '03-实现架构/03.1-词法分析与语法解析',
            '03-实现架构/03.2-AST与IR',
            '03-实现架构/03.3-编译器设计',
            '03-实现架构/03.4-Top-Down求值器',
            '03-实现架构/03.5-索引与优化',
            '03-实现架构/03.6-部分求值技术'
          ]
        },
        {
          title: '🌐 生态系统',
          collapsable: true,
          children: [
            '04-生态系统/04.1-Kubernetes集成',
            '04-生态系统/04.2-Gatekeeper详解'
          ]
        },
        {
          title: '💼 应用场景',
          collapsable: true,
          children: [
            '05-应用场景/05.1-访问控制(RBAC)',
            '05-应用场景/05.2-API网关授权'
          ]
        },
        {
          title: '🎓 形式化证明',
          collapsable: true,
          children: [
            '06-形式化证明/06.1-Datalog理论基础',
            '06-形式化证明/06.2-Rego形式化语义'
          ]
        },
        {
          title: '🗺️ 概念图谱',
          collapsable: true,
          children: [
            '07-概念图谱/07.1-核心概念定义'
          ]
        },
        {
          title: '💡 最佳实践',
          collapsable: true,
          children: [
            '08-最佳实践/08.1-策略设计模式',
            '08-最佳实践/08.2-性能优化指南'
          ]
        },
        {
          title: '🏭 生产实战',
          collapsable: true,
          children: [
            '09-生产实战/09.1-电商API授权实战',
            '09-生产实战/09.2-金融K8s策略实战',
            '09-生产实战/09.3-SaaS多租户WASM实战'
          ]
        },
        {
          title: '🎯 工具与资源',
          collapsable: true,
          children: [
            'QUICK_REFERENCE',
            'FAQ',
            'LEARNING_PATH',
            'GLOSSARY',
            'VERSION_COMPATIBILITY',
            'PRODUCTION_CASES',
            'CHECKLIST'
          ]
        }
      ],
      
      '/examples/': [
        {
          title: '🧪 代码示例',
          collapsable: false,
          children: [
            '',
            '01-hello-world/',
            '02-basic-rbac/',
            '03-kubernetes-admission/',
            '04-performance-optimization/'
          ]
        }
      ]
    },
    
    // 搜索
    search: true,
    searchMaxSuggestions: 10,
    
    // 最后更新时间
    lastUpdated: '最后更新',
    
    // 编辑链接
    editLinks: true,
    editLinkText: '在 GitHub 上编辑此页',
    repo: 'YOUR_USERNAME/OPA',
    repoLabel: 'GitHub',
    docsRepo: 'YOUR_USERNAME/OPA',
    docsDir: 'docs',
    docsBranch: 'main',
    
    // 平滑滚动
    smoothScroll: true
  },
  
  // Markdown配置
  markdown: {
    lineNumbers: true,
    extractHeaders: ['h2', 'h3', 'h4'],
    toc: {
      includeLevel: [2, 3, 4]
    }
  },
  
  // 插件
  plugins: [
    '@vuepress/back-to-top',
    '@vuepress/medium-zoom',
    '@vuepress/nprogress',
    [
      '@vuepress/pwa',
      {
        serviceWorker: true,
        updatePopup: {
          message: "发现新内容可用",
          buttonText: "刷新"
        }
      }
    ],
    [
      '@vuepress/search',
      {
        searchMaxSuggestions: 10
      }
    ],
    [
      'vuepress-plugin-code-copy',
      {
        align: 'bottom',
        color: '#3eaf7c',
        successText: '已复制'
      }
    ]
  ],
  
  // 构建配置
  dest: 'dist',
  
  // 额外的配置
  head: [
    ['link', { rel: 'icon', href: '/favicon.ico' }],
    ['meta', { name: 'author', content: 'OPA技术文档项目' }],
    ['meta', { name: 'keywords', content: 'OPA,Open Policy Agent,Rego,策略引擎,RBAC,Kubernetes,技术文档' }],
    ['meta', { name: 'viewport', content: 'width=device-width,initial-scale=1,user-scalable=no' }]
  ]
};


