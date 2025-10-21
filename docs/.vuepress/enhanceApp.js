// 应用级别的增强
export default ({
  Vue, // VuePress 正在使用的 Vue 构造函数
  options, // 附加到根实例的一些选项
  router, // 当前应用的路由实例
  siteData // 站点元数据
}) => {
  // 添加全局组件或指令
  
  // 路由守卫：页面跳转时滚动到顶部
  router.afterEach((to, from) => {
    if (to.path !== from.path) {
      if (typeof window !== 'undefined') {
        window.scrollTo(0, 0);
      }
    }
  });
}

