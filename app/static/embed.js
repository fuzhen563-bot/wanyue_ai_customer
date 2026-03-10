/**
 * 万岳AI客服 - 嵌入式客服脚本
 * 用于将AI客服嵌入到任意网站
 * 
 * 使用方法:
 * 1. 在管理后台创建嵌入配置
 * 2. 获取嵌入代码
 * 3. 将代码添加到网站HTML的<head>标签中
 */

(function() {
    'use strict';

    // 配置
    let config = {
        authCode: null,
        apiUrl: null,
        sessionKey: null,
        config: null
    };

    // 客服窗口状态
    let widgetState = {
        isOpen: false,
        messages: [],
        isTyping: false
    };

    // 初始化
    function init() {
        if (!window.wanyueConfig) {
            console.error('万岳AI客服: 请先配置wanyueConfig');
            return;
        }

        config.authCode = window.wanyueConfig.authCode;
        config.apiUrl = window.wanyueConfig.apiUrl || window.location.origin;

        // 验证授权
        verifyAuth();
    }

    // 验证授权
    async function verifyAuth() {
        try {
            const domain = window.location.hostname;
            const response = await fetch(`${config.apiUrl}/api/public/embed/verify`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    auth_code: config.authCode,
                    domain: domain
                })
            });

            const data = await response.json();

            if (!data.valid) {
                console.error('万岳AI客服: 授权验证失败 -', data.error);
                return;
            }

            config.config = data.config;
            initSession();
        } catch (error) {
            console.error('万岳AI客服: 授权验证请求失败', error);
        }
    }

    // 初始化会话
    async function initSession() {
        try {
            const domain = window.location.hostname;
            const response = await fetch(
                `${config.apiUrl}/api/public/embed/init?auth_code=${config.authCode}&domain=${encodeURIComponent(domain)}`
            );

            const data = await response.json();

            if (!data.valid) {
                console.error('万岳AI客服: 会话初始化失败 -', data.error);
                // 如果是余额不足，显示提示
                if (data.error === 'balance_insufficient') {
                    alert('抱歉，您的账户余额不足，请先充值后再使用客服功能。');
                }
                return;
            }

            config.sessionKey = data.session_key;
            widgetState.config = data;

            // 创建客服窗口
            createWidget();

            // 显示欢迎消息
            addMessage({
                role: 'assistant',
                content: data.welcome_message || '您好！请问有什么可以帮助您？'
            });

        } catch (error) {
            console.error('万岳AI客服: 会话初始化请求失败', error);
        }
    }

    // 创建客服窗口组件
    function createWidget() {
        // 创建按钮
        const button = document.createElement('div');
        button.id = 'wanyue-widget-btn';
        button.innerHTML = `<svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2">
            <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path>
        </svg>`;
        button.style.cssText = `
            position: fixed;
            bottom: 24px;
            right: 24px;
            width: 60px;
            height: 60px;
            background: linear-gradient(135deg, ${widgetState.config.theme_color || '#2563eb'}, #8b5cf6);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            box-shadow: 0 8px 24px rgba(37, 99, 235, 0.4);
            z-index: 999999;
            transition: all 0.3s ease;
        `;
        button.onmouseover = () => { button.style.transform = 'scale(1.1)'; button.style.boxShadow = '0 12px 32px rgba(37, 99, 235, 0.5)'; };
        button.onmouseout = () => { button.style.transform = 'scale(1)'; button.style.boxShadow = '0 8px 24px rgba(37, 99, 235, 0.4)'; };
        button.onclick = toggleWidget;

        // 创建聊天窗口
        const chatWindow = document.createElement('div');
        chatWindow.id = 'wanyue-widget';
        chatWindow.style.cssText = `
            position: fixed;
            bottom: 100px;
            right: 24px;
            width: 380px;
            height: 560px;
            background: #ffffff;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.15);
            z-index: 999999;
            display: none;
            flex-direction: column;
            overflow: hidden;
            border: 1px solid rgba(0, 0, 0, 0.08);
        `;

        const position = widgetState.config.position || 'right';
        chatWindow.style.right = position === 'left' ? 'auto' : '24px';
        chatWindow.style.left = position === 'left' ? '24px' : 'auto';

        chatWindow.innerHTML = `
            <div class="wanyue-header" style="
                background: linear-gradient(135deg, ${widgetState.config.theme_color || '#2563eb'}, #8b5cf6);
                padding: 16px 20px;
                display: flex;
                align-items: center;
                justify-content: space-between;
                flex-shrink: 0;
            ">
                <div style="display: flex; align-items: center; gap: 12px;">
                    <div style="width: 40px; height: 40px; background: rgba(255,255,255,0.2); border-radius: 12px; display: flex; align-items: center; justify-content: center;">
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2">
                            <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path>
                        </svg>
                    </div>
                    <div>
                        <div style="color: white; font-weight: 600; font-size: 15px;">AI 客服</div>
                        <div style="color: rgba(255,255,255,0.8); font-size: 12px; display: flex; align-items: center; gap: 4px;">
                            <span style="width: 6px; height: 6px; background: #34d399; border-radius: 50%; display: inline-block;"></span>
                            在线回复
                        </div>
                    </div>
                </div>
                <div style="display: flex; gap: 8px;">
                    <span class="wanyue-minimize" style="color: white; cursor: pointer; padding: 4px;">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <line x1="5" y1="12" x2="19" y2="12"></line>
                        </svg>
                    </span>
                    <span class="wanyue-close" style="color: white; cursor: pointer; padding: 4px;">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <line x1="18" y1="6" x2="6" y2="18"></line>
                            <line x1="6" y1="6" x2="18" y2="18"></line>
                        </svg>
                    </span>
                </div>
            </div>
            <div class="wanyue-messages" style="
                flex: 1;
                overflow-y: auto;
                padding: 16px;
                display: flex;
                flex-direction: column;
                gap: 12px;
                background: #f8fafc;
            "></div>
            <div class="wanyue-input-area" style="
                padding: 16px;
                background: white;
                border-top: 1px solid #e2e8f0;
                display: flex;
                gap: 10px;
                flex-shrink: 0;
            ">
                <input type="text" class="wanyue-input" placeholder="输入您的问题..." style="
                    flex: 1;
                    padding: 12px 16px;
                    background: #f1f5f9;
                    border: 1px solid #e2e8f0;
                    border-radius: 24px;
                    color: #1e293b;
                    font-size: 14px;
                    outline: none;
                    transition: all 0.2s;
                ">
                <button class="wanyue-send" style="
                    width: 44px;
                    height: 44px;
                    background: linear-gradient(135deg, ${widgetState.config.theme_color || '#2563eb'}, #8b5cf6);
                    border: none;
                    border-radius: 50%;
                    cursor: pointer;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    box-shadow: 0 4px 12px rgba(37, 99, 235, 0.3);
                    transition: all 0.2s;
                ">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2">
                        <line x1="22" y1="2" x2="11" y2="13"></line>
                        <polygon points="22 2 15 22 11 13 2 9 22 2"></polygon>
                    </svg>
                </button>
            </div>
        `;

        // 添加事件
        chatWindow.querySelector('.wanyue-close').onclick = toggleWidget;
        
        const input = chatWindow.querySelector('.wanyue-input');
        const sendBtn = chatWindow.querySelector('.wanyue-send');
        
        input.onfocus = () => { input.style.borderColor = widgetState.config.theme_color || '#2563eb'; input.style.boxShadow = '0 0 0 3px rgba(37, 99, 235, 0.1)'; };
        input.onblur = () => { input.style.borderColor = '#e2e8f0'; input.style.boxShadow = 'none'; };
        
        input.onkeypress = (e) => {
            if (e.key === 'Enter') sendMessage();
        };
        sendBtn.onmouseover = () => { sendBtn.style.transform = 'scale(1.05)'; };
        sendBtn.onmouseout = () => { sendBtn.style.transform = 'scale(1)'; };
        sendBtn.onclick = sendMessage;

        document.body.appendChild(button);
        document.body.appendChild(chatWindow);
    }

    // 切换窗口
    function toggleWidget() {
        const widget = document.getElementById('wanyue-widget');
        const btn = document.getElementById('wanyue-widget-btn');
        
        widgetState.isOpen = !widgetState.isOpen;
        widget.style.display = widgetState.isOpen ? 'flex' : 'none';
        btn.style.transform = widgetState.isOpen ? 'rotate(90deg)' : 'rotate(0)';
        
        if (widgetState.isOpen) {
            widget.querySelector('.wanyue-input').focus();
            // 显示欢迎消息
            if (widgetState.messages.length === 0) {
                const welcomeMsg = widgetState.config.welcome_message || '您好！我是AI客服，请问有什么可以帮助您？';
                addMessage({ role: 'assistant', content: welcomeMsg });
            }
        }
    }

    // 添加消息
    function addMessage(message) {
        const messagesEl = document.querySelector('.wanyue-messages');
        if (!messagesEl) return;

        const messageEl = document.createElement('div');
        messageEl.style.cssText = `
            display: flex;
            gap: 10px;
            align-items: flex-end;
            animation: wanyueFadeIn 0.3s ease;
            max-width: 85%;
            ${message.role === 'user' ? 'margin-left: auto;' : ''}
        `;

        const isUser = message.role === 'user';

        messageEl.innerHTML = isUser ? `
            <div style="
                padding: 12px 16px;
                border-radius: 18px 18px 4px 18px;
                font-size: 14px;
                line-height: 1.5;
                color: white;
                background: linear-gradient(135deg, ${widgetState.config.theme_color || '#2563eb'}, #8b5cf6);
                box-shadow: 0 2px 8px rgba(37, 99, 235, 0.2);
            ">${message.content}</div>
            <div style="
                width: 28px;
                height: 28px;
                border-radius: 50%;
                background: linear-gradient(135deg, ${widgetState.config.theme_color || '#2563eb'}, #8b5cf6);
                display: flex;
                align-items: center;
                justify-content: center;
                flex-shrink: 0;
                box-shadow: 0 2px 8px rgba(37, 99, 235, 0.2);
            ">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="white">
                    <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                    <circle cx="12" cy="7" r="4"></circle>
                </svg>
            </div>
        ` : `
            <div style="
                width: 28px;
                height: 28px;
                border-radius: 50%;
                background: linear-gradient(135deg, #10b981, #34d399);
                display: flex;
                align-items: center;
                justify-content: center;
                flex-shrink: 0;
                box-shadow: 0 2px 8px rgba(16, 185, 129, 0.2);
            ">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="white">
                    <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path>
                </svg>
            </div>
            <div style="
                padding: 12px 16px;
                border-radius: 18px 18px 18px 4px;
                font-size: 14px;
                line-height: 1.5;
                color: #1e293b;
                background: white;
                border: 1px solid #e2e8f0;
                box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
            ">${message.content}</div>
        `;

        messagesEl.appendChild(messageEl);
        messagesEl.scrollTop = messagesEl.scrollHeight;

        widgetState.messages.push(message);
    }

    // 发送消息
    async function sendMessage() {
        const input = document.querySelector('.wanyue-input');
        const message = input.value.trim();
        
        if (!message) return;

        input.value = '';

        // 添加用户消息
        addMessage({ role: 'user', content: message });

        // 显示typing
        showTyping();

        try {
            // 使用流式API
            const response = await fetch(`${config.apiUrl}/api/public/chat/stream`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    message: message,
                    session_key: config.sessionKey,
                    embed_config_id: widgetState.config.id,
                    use_knowledge_base: true
                })
            });

            hideTyping();

            if (!response.ok || !response.body) {
                addMessage({ role: 'assistant', content: '抱歉，请稍后再试。' });
                return;
            }

            // 检查余额不足错误
            const firstChunk = await response.clone().text();
            if (firstChunk.includes('balance_insufficient')) {
                addMessage({ role: 'assistant', content: '抱歉，您的账户余额不足，请先充值后再使用客服功能。' });
                return;
            }

            // 创建AI消息容器
            const messagesEl = document.querySelector('.wanyue-messages');
            const messageEl = document.createElement('div');
            messageEl.style.cssText = `
                display: flex;
                gap: 10px;
                align-items: flex-end;
                animation: wanyueFadeIn 0.3s ease;
                max-width: 85%;
            `;
            messageEl.innerHTML = `
                <div style="
                    width: 28px;
                    height: 28px;
                    border-radius: 50%;
                    background: linear-gradient(135deg, #10b981, #34d399);
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    flex-shrink: 0;
                    box-shadow: 0 2px 8px rgba(16, 185, 129, 0.2);
                ">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="white">
                        <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path>
                    </svg>
                </div>
                <div style="
                    padding: 12px 16px;
                    border-radius: 18px 18px 18px 4px;
                    font-size: 14px;
                    line-height: 1.5;
                    color: #1e293b;
                    background: white;
                    border: 1px solid #e2e8f0;
                    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
                " id="wanyue-ai-content"></div>
            `;
            messagesEl.appendChild(messageEl);
            messagesEl.scrollTop = messagesEl.scrollHeight;

            const reader = response.body.getReader();
            const decoder = new TextDecoder();
            const aiContentEl = messageEl.querySelector('#wanyue-ai-content');
            let fullContent = '';
            
            while (true) {
                const { done, value } = await reader.read();
                if (done) break;
                
                const chunk = decoder.decode(value, { stream: true });
                const lines = chunk.split('\n');
                
                for (const line of lines) {
                    if (line.startsWith('data: ')) {
                        try {
                            const data = JSON.parse(line.slice(6));
                            if (data.content) {
                                fullContent += data.content;
                                aiContentEl.textContent = fullContent;
                                messagesEl.scrollTop = messagesEl.scrollHeight;
                            }
                            if (data.done) {
                                break;
                            }
                        } catch (e) {
                            // Skip invalid JSON
                        }
                    }
                }
            }
            
            // 保存到消息列表
            widgetState.messages.push({ role: 'assistant', content: aiContentEl.textContent });

        } catch (error) {
            hideTyping();
            addMessage({ role: 'assistant', content: '网络错误，请稍后再试。' });
        }
    }

    // 显示typing
    function showTyping() {
        const messagesEl = document.querySelector('.wanyue-messages');
        const typingEl = document.createElement('div');
        typingEl.className = 'wanyue-typing';
        typingEl.style.cssText = `
            display: flex;
            gap: 10px;
            align-items: flex-end;
            animation: wanyueFadeIn 0.3s ease;
        `;
        typingEl.innerHTML = `
            <div style="
                width: 28px;
                height: 28px;
                border-radius: 50%;
                background: linear-gradient(135deg, #10b981, #34d399);
                display: flex;
                align-items: center;
                justify-content: center;
                box-shadow: 0 2px 8px rgba(16, 185, 129, 0.2);
            ">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="white">
                    <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path>
                </svg>
            </div>
            <div style="
                padding: 12px 16px;
                background: white;
                border: 1px solid #e2e8f0;
                border-radius: 18px 18px 18px 4px;
                box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
            ">
                <span style="
                    display: inline-block;
                    width: 8px;
                    height: 8px;
                    background: #94a3b8;
                    border-radius: 50%;
                    margin: 0 2px;
                    animation: wanyueBounce 1.4s infinite;
                "></span>
                <span style="
                    display: inline-block;
                    width: 8px;
                    height: 8px;
                    background: #94a3b8;
                    border-radius: 50%;
                    margin: 0 2px;
                    animation: wanyueBounce 1.4s infinite;
                    animation-delay: 0.2s;
                "></span>
                <span style="
                    display: inline-block;
                    width: 8px;
                    height: 8px;
                    background: #94a3b8;
                    border-radius: 50%;
                    margin: 0 2px;
                    animation: wanyueBounce 1.4s infinite;
                    animation-delay: 0.4s;
                "></span>
            </div>
        `;
        messagesEl.appendChild(typingEl);
        messagesEl.scrollTop = messagesEl.scrollHeight;
    }

    // 隐藏typing
    function hideTyping() {
        const typingEl = document.querySelector('.wanyue-typing');
        if (typingEl) typingEl.remove();
    }

    // 添加动画样式
    const style = document.createElement('style');
    style.textContent = `
        @keyframes wanyueFadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }
        @keyframes wanyueBounce {
            0%, 60%, 100% { transform: translateY(0); }
            30% { transform: translateY(-6px); }
        }
    `;
    document.head.appendChild(style);

    // 页面加载完成后初始化
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }

})();
