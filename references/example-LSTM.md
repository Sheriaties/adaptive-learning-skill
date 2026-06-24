1|---
2|title: "长短期记忆网络（LSTM）"
3|source: "动手学深度学习 2.0.0 (d2l.ai)"
4|url: https://zh.d2l.ai/chapter_recurrent-modern/lstm.html
5|tags: [LSTM, 循环神经网络, 门控机制]
6|---
7|
8|⻓短期记忆⽹络（ ）  (../_
9|9.2. LSTM S
10| MXNet (https://zh-v2.d2l.ai/d2l-zh.pdf)  PyTorch (https://zh-v2.d2l.ai/d2
11|⻓短期记忆⽹络（ ）
12|9.2. LSTM
13| COLAB [MXNET]
14|esearch.google.com/github/d2l-
15|ster/chapter_recurrent-
16|pynb)
17| SAGEMAKER STUDIO LAB
18|(https://studiolab.sagemaker.aw
19|ai/d2l-pytorch-sagemaker-
20|studio-
21|lab/blob/main/GettingStarted-
22|D2L.ipynb)
23|⻓期以来，隐变量模型存在着⻓期信息保存和短期输⼊缺失
24|的问题。 解决这⼀问题的最早⽅法之⼀是⻓短期存储器
25|（long short-term memory，LSTM） (Hochreiter and
26|Schmidhuber, 1997
27|(../chapter_references/zreferences.html#id68))。 它有许多
28|与⻔控循环单元（ 9.1节 (gru.html#sec-
29|（ 9.1节 (gru.html#sec-gru)）⼀样的属性。
30|有趣的是，⻓短期记忆⽹络的设计⽐⻔控循环单元稍微复杂
31|⼀些， 却⽐⻔控循环单元早诞⽣了近20年。
32|⻔控记忆元
33|9.2.1.
34|可以说，⻓短期记忆⽹络的设计灵感来⾃于计算机的逻辑
35|⻔。 ⻓短期记忆⽹络引⼊了记忆元（memory cell），或简称
36|为单元（cell）。 有些⽂献认为记忆元是隐状态的⼀种特殊类
37|型， 它们与隐状态具有相同的形状，其设计⽬的是⽤于记录
38|附加的信息。 为了控制记忆元，我们需要许多⻔。 其中⼀个
39|
40|⻔⽤来从单元中输出条⽬，我们将其称为输出⻔（output
41|gate）。 另外⼀个⻔⽤来决定何时将数据读⼊单元，我们将其
42|称为输⼊⻔（input gate）。 我们还需要⼀种机制来重置单元
43|的内容，由遗忘⻔（forget gate）来管理， 这种设计的动机
44|与⻔控循环单元相同， 能够通过专⽤机制决定什么时候记忆
45|或忽略隐状态中的输⼊。 让我们看看这在实践中是如何运作
46|的。
47|输⼊⻔、忘记⻔和输出⻔
48|9.2.1.1.
49|就如在⻔控循环单元中⼀样， 当前时间步的输⼊和前⼀个时
50|间步的隐状态 作为数据送⼊⻓短期记忆⽹络的⻔中， 如 图
51|9.2.1所示。 它们由三个具有sigmoid激活函数的全连接层处
52|理， 以计算输⼊⻔、遗忘⻔和输出⻔的值。 因此，这三个⻔
53|的值都在(0,1)的范围内。
54|图9.2.1 ⻓短期记忆模型中的输⼊⻔、遗忘⻔和输出⻔
55|我们来细化⼀下⻓短期记忆⽹络的数学表达。 假设有h个隐藏
56|单元，批量⼤⼩为n，输⼊数为d。 因此，输⼊为X
57|t
58|∈ Rn×d
59|， 前⼀时间步的隐状态为H
60|t−1
61|∈ Rn×h 。 相应地，时间步t
62|的⻔被定义如下： 输⼊⻔是I
63|t
64|∈ Rn×h ， 遗忘⻔是
65|F
66|t
67|∈ Rn×h ， 输出⻔是O
68|t
69|∈ Rn×h 。 它们的计
70|h ， 输出⻔是O
71|t
72|∈ Rn×h 。 它们的计算⽅法如下：
73|I = σ(X W + H W + b ),
74|t t xi t−1 hi i (9.2.1)
75|F = σ(X W + H W + b ),
76|t t xf t−1 hf f
77|O = σ(X W + H W + b ),
78|t t xo t−1 ho o
79|其中W
80|xi
81|,W
82|xf
83|,W
84|xo
85|∈ Rd×h 和W
86|hi
87|,W
88|hf
89|,W
90|ho
91|∈ Rh×h
92|是权重参数， b
93|i
94|,b
95|f
96|,b
97|o
98|∈ R1×h 是偏置参数。
99|
100|候选记忆元
101|9.2.1.2.
102|由于还没有指定各种⻔的操作，所以先介绍候选记忆元
103|~
104|（candidate memory cell） C t ∈ Rn×h。 它的计算与上⾯描
105|述的三个⻔的计算类似， 但是使⽤tanh函数作为激活函数，
106|函数的值范围为(−1,1)。 下⾯导出在时间步t处的⽅程：
107|~
108|C = tanh(X W + H W + b ),
109|t t xc t−1 hc c (9.2.2)
110|其中W
111|xc
112|∈ Rd×h 和 W
113|hc
114|∈ Rh×h 是权重参数， b
115|c
116|∈ R1×h
117|是偏置参数。
118|候选记忆元的如 图9.2.2所示。
119|图9.2.2 ⻓短期记忆模型中的候选记忆元
120|记忆元
121|9.2.1.3.
122|在⻔控循环单元中，有⼀种机制来控制输⼊和遗忘（或跳
123|过）。 类似地，在⻓短期记忆⽹络中，也有两个⻔⽤于这样的
124|~
125|⽬的： 输⼊⻔I
126|t
127|控制采⽤多少来⾃C
128|t
129|的新数据， ⽽遗忘⻔F
130|t
131|控制保留多少过去的 记忆元C
132|t−1
133|∈ Rn×h 的内容。 使⽤按元
134|素乘法，得出：
135|~
136|C = F ⊙ C + I ⊙ C .
137|t t t−1 t t (9.2.3)
138|如果遗忘⻔始终为1且输⼊⻔始终为0， 则过去的记忆元C
139|t−1
140|将随时间被保存并传递到当前时间步。 
141|）。 类似地，在⻓短期记忆⽹络中，也有两个⻔⽤于这样的
142|~
143|⽬的： 输⼊⻔I
144|t
145|控制采⽤多少来⾃C
146|t
147|的新数据， ⽽遗忘⻔F
148|t
149|控制保留多少过去的 记忆元C
150|t−1
151|∈ Rn×h 的内容。 使⽤按元
152|素乘法，得出：
153|~
154|C = F ⊙ C + I ⊙ C .
155|t t t−1 t t (9.2.3)
156|如果遗忘⻔始终为1且输⼊⻔始终为0， 则过去的记忆元C
157|t−1
158|将随时间被保存并传递到当前时间步。 引⼊这种设计是为了
159|缓解梯度消失问题， 并更好地捕获序列中的⻓距离依赖关
160|系。
161|
162|这样我们就得到了计算记忆元的流程图，如 图9.2.3。
163|图9.2.3 在⻓短期记忆⽹络模型中计算记忆元
164|隐状态
165|9.2.1.4.
166|最后，我们需要定义如何计算隐状态 H
167|t
168|∈ Rn×h， 这就是输
169|出⻔发挥作⽤的地⽅。 在⻓短期记忆⽹络中，它仅仅是记忆
170|元的tanh的⻔控版本。 这就确保了H
171|t
172|的值始终在区间
173|(−1,1)内：
174|H = O ⊙ tanh(C ).
175|t t t (9.2.4)
176|只要输出⻔接近1，我们就能够有效地将所有记忆信息传递给
177|预测部分， ⽽对于输出⻔接近0，我们只保留记忆元内的所有
178|信息，⽽不需要更新隐状态。
179|图9.2.4提供了数据流的图形化演示。
180|图9.2.4 在⻓短期记忆模型中计算隐状态
181|我们需要定义如何计算隐状态 H
182|t
183|∈ Rn×h， 这就是输
184|出⻔发挥作⽤的地⽅。 在⻓短期记忆⽹络中，它仅仅是记忆
185|元的tanh的⻔控版本。 这就确保了H
186|t
187|的值始终在区间
188|(−1,1)内：
189|H = O ⊙ tanh(C ).
190|t t t (9.2.4)
191|只要输出⻔接近1，我们就能够有效地将所有记忆信息传递给
192|预测部分， ⽽对于输出⻔接近0，我们只保留记忆元内的所有
193|信息，⽽不需要更新隐状态。
194|图9.2.4提供了数据流的图形化演示。
195|图9.2.4 在⻓短期记忆模型中计算隐状态
196|
197|从零开始实现
198|9.2.2.
199|现在，我们从零开始实现⻓短期记忆⽹络。 与 8.5节
200|(../chapter_recurrent-neural-networks/rnn-scratch.html#sec-
201|rnn-scratch)中的实验相同， 我们⾸先加载时光机器数据集。
202|from mxnet import np, npx
203|from mxnet.gluon import rnn
204|from d2l import mxnet as d2l
205|npx.set_np()
206|batch_size, num_steps = 32, 35
207|train_iter, vocab = d2l.load_data_time_machine(b
208|import torch
209|from torch import nn
210|from d2l import torch as d2l
211|batch_size, num_steps = 32, 35
212|train_iter, vocab = d2l.load_data_time_machine(b
213|import tensorflow as tf
214|from d2l import tensorfl
215|import paddle.nn.functional as Function
216|from paddle import nn
217|batch_size, num_steps = 32, 35
218|train_iter, vocab = d2l.load_data_time_machine(b
219|初始化模型参数
220|9.2.2.1.
221|接下来，我们需要定义和初始化模型参数。 如前所述，超参
222|数num_hiddens定义隐藏单元的数量。 我们按照标准差
223|0.01的⾼斯分布初始化权重，并将偏置项设为0。
224|
225|def get_lstm_params(vocab_size, num_hiddens, dev
226|num_inputs = num_outputs = vocab_size
227|def normal(shape):
228|return np.random.normal(scale=0.01, size=
229|def three():
230|return (normal((num_inputs, num_hiddens)
231|normal((num_hiddens, num_hiddens
232|np.zeros(num_hiddens, ctx=device
233|W_xi, W_hi, b_i = three() # 输⼊⻔参数
234|W_xf, W_hf, b_f = three() # 遗忘⻔参数
235|W_xo, W_ho, b_o = three() # 输出⻔参数
236|W_xc, W_hc, b_c = three() # 候选记忆元参数
237|# 输出层参数
238|W_hq = normal((num_hiddens, num_outputs))
239|b_q = np.zeros(num_outputs, ctx=device)
240|# 附加梯度
241|
242|hree() # 候选记忆元参数
243|# 输出层参数
244|W_hq = normal((num_hiddens, num_outputs))
245|b_q = torch.zeros(num_outputs, device=device
246|# 附加梯度
247|params = [W_xi, W_hi, b_i, W_xf, W_hf, b_f, W
248|b_c, W_hq, b_q]
249|for param in params:
250|param.requires_grad_(True)
251|return params
252|
253|def get_lstm_params(vocab_size, num_hiddens):
254|num_inputs = num_outputs = vocab_size
255|def normal(shape):
256|return tf.Variable(tf.random.normal(shap
257|mean=
258|def three():
259|return (normal((num_inputs, num_hiddens)
260|normal((num_hiddens, num_hiddens
261|tf.Variable(tf.zeros(num_hiddens
262|W_xi, W_hi, b_i = three() # 输⼊⻔参数
263|W_xf, W_hf, b_f = three() # 遗忘⻔参数
264|W_xo, W_ho, b_o = three() # 输出⻔参数
265|W_xc, W_hc, b_c = three() # 候选记忆元参数
266|# 输出层参数
267|W_hq = normal((num_hiddens, num_outputs))
268|b_q = tf.Variable(tf.zeros(num_outputs), dty
269|# 附加梯度
270|params = [W_xi, W_hi, b_i
271|eros([num_outputs])
272|# 附加梯度
273|params = [W_xi, W_hi, b_i, W_xf, W_hf, b_f, W
274|b_c, W_hq, b_q]
275|for param in params:
276|param.stop_gradient = False
277|return params
278|定义模型
279|9.2.2.2.
280|在初始化函数中， ⻓短期记忆⽹络的隐状态需要返回⼀个额
281|外的记忆元， 单元的值为0，形状为（批量⼤⼩，隐藏单元
282|数）。 因此，我们得到以下的状态初始化。
283|
284|def init_lstm_state(batch_size, num_hiddens, dev
285|return (np.zeros((batch_size, num_hiddens),
286|np.zeros((batch_size, num_hiddens),
287|def init_lstm_state(batch_size, num_hiddens, dev
288|return (torch.zeros((batch_size, num_hiddens
289|torch.zeros((batch_size, num_hiddens
290|def init_lstm_state(batch_size, num_hiddens):
291|return (tf.zeros(shape=(batch_size, num_hidd
292|tf.zeros(shape=(batch_size, num_hidd
293|def init_lstm_state(batch_size, num_hiddens):
294|return (paddle.zeros([batch_size, num_hidden
295|paddle.zeros([batch_size
296|moid(np.dot(X, W_xf) + np.dot
297|O = npx.sigmoid(np.dot(X, W_xo) + np.dot
298|C_tilda = np.tanh(np.dot(X, W_xc) + np.d
299|C = F * C + I * C_tilda
300|H = O * np.tanh(C)
301|