package imagemeacao;

import java.awt.Color;
import java.awt.Dimension;
import java.awt.Image;
import java.awt.Toolkit;
import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Timer;
import java.util.TimerTask;
import javax.swing.JOptionPane;
import javax.swing.UIManager;

public class JanelaPrincipal extends javax.swing.JFrame {
    static Splash splash;
    static Dicionario listaAnimais;
    static Dicionario listaAcoes;
    static Dicionario listaPaises;
    static Dicionario listaEsportes;
    static Dicionario listaNovelas;
    static Dicionario listaAdjetivos;
    static Dicionario listaQualquerPalavra;
    static Dicionario listaNomes;
    static Dicionario listaDificeis;
    static Dicionario listaCriaturas;
    static HashMap<Integer, Dicionario> dicionarios = new HashMap<Integer, Dicionario>();
    Integer n_dicionariosAtivos = 0;
    String atual = "Nenhuma palavra foi sorteada!";
    String conteudo;
    boolean sorteou = false;
    Timer cronometro = new Timer("Cronometro");
    long time_atual = 60;
    long time = 60;
    static JanelaPrincipal janela;

    public JanelaPrincipal() {
        initComponents();
        setLocationRelativeTo(null);
        lerDicionarios();
        l_tempo.setText(formatador(time_atual));
        
       // Muta o icone do programa
       Image img_tmp = Toolkit.getDefaultToolkit().getImage("imagens/icon.png");
       setIconImage(img_tmp);
       img_tmp = null;
       System.gc();
    }

    public static void ajeitadicionarios() throws Exception {

        ArrayList<String> todas = new ArrayList<String>();
        ArrayList<String> a = new ArrayList<String>();
        a.add("listaAcoes.dic");
        a.add("listaAdjetivos.dic");
        a.add("listaAnimais.dic");
        a.add("listaCriaturas.dic");
        a.add("listaEsportes.dic");
        a.add("listaNovelas.dic");
        a.add("listaPaises.dic");
        a.add("listaNomes.dic");
        a.add("listaDificeis.dic");
        a.add("listaQualquerPalavra.dic");


        for (String arquivo : a) {
            String saida = "";
            //LinkedList<String> l = new LinkedList<String>();
            BufferedReader reader = new BufferedReader(new InputStreamReader(new FileInputStream("dicionarios/" + arquivo)));
            String line;
            while ((line = reader.readLine()) != null) {
                line = line.trim();
                if (line.equalsIgnoreCase("") || line.length() < 3) {
                    continue;
                }
                if (line.contains("/")) {
                    line = line.split("/")[0];
                }
                String n = new String(line.substring(0, 1).toUpperCase() + line.substring(1, line.length()));
                if (!todas.contains(n)) {
                    todas.add(n);
                    saida += n + "\n";
                    System.out.println(n);
                }
            }
            reader.close();

            escreveArquivo(saida, arquivo);
        }

    }

    /*
     * Escreve uma string em um arquivo de texto.
     * @param conteudo String a ser gravada no arquivo
     * @param fileName Nome do arquivo a ser sobreescrito.
     * @throws IOException Geralmente ocorre quando o arquivo nao e encontrado.
     */
    public static void escreveArquivo(String conteudo, String fileName) throws IOException {
        try {
            PrintWriter out = new PrintWriter(new FileWriter(fileName));
            out.print(conteudo);
            out.close();
        } catch (IOException ex) {
        }
    } //Fim da metodo escreveArquivo

    public static void main(String args[]) {

        try {
            UIManager.setLookAndFeel("com.sun.java.swing.plaf.windows.WindowsLookAndFeel");
        } catch (Exception e) {
            e.printStackTrace();
        }
        java.awt.EventQueue.invokeLater(new Runnable() {

            public void run() {
              splash = new Splash();
              janela = new JanelaPrincipal();
            }
        });
    }

    void b_sortearActionPerformed() {
        b_sortearActionPerformed(null);
    }

    private void decrementarTempo() {
        if (time_atual <= 0) {
            cronometro.purge();
            l_tempo.setText("Tempo Esgotado!");
            try {
                cronometro.purge();
                cronometro.cancel();
                cronometro = null;
                System.gc();
            } catch (Exception e) {
            }
            somTempoEsgotado();
        } else {
            l_tempo.setText(formatador(time_atual--));
        }
    }

    private String formatador(long tempo) {
        if (tempo < 60 && tempo > 9) {
            return "00:" + tempo;
        } else {
            if (tempo < 10) {
                return "00:0" + tempo;
            } else {
                if (tempo % 60 < 10) {
                    return "0" + (int) Math.floor(tempo / 60) + ":0" + (int) tempo % 60;
                } else {
                    return "0" + (int) Math.floor(tempo / 60) + ":" + (int) tempo % 60;
                }





            }
        }
    }

    private void iniciarCronometro() {
        try {
            cronometro.purge();
            cronometro.cancel();
            cronometro = null;
            System.gc();
        } catch (Exception e) {
        }

        cronometro = cronometro = new Timer("Cronometro");
        time_atual = time;

        this.cronometro.schedule(new TimerTask() {

            @Override
            public void run() {
                if (time_atual >= 0) {
                    janela.decrementarTempo();
                } else {
                    Thread.currentThread().interrupt();
                }
            }
        }, 0, 1000);


    }

    private void lerDicionarios() {
        dicionarios.clear();
        n_dicionariosAtivos = 0;


        if (c_acoes.getState()) {
            try {
                listaAcoes = lerLista("Ação", "Sempre será um verbo.\nEx: Rebaixar.", "listaAcoes.dic");
                dicionarios.put(n_dicionariosAtivos++, listaAcoes);
            } catch (Exception ex) {
                //JOptionPane.showMessageDialog(this, "Um erro ocorreu ao ler o dicionário AÇÕES. O Dicinário não poderá ser usado.", "Erro ao carregar um dos dicionários", JOptionPane.WARNING_MESSAGE);
                c_acoes.setSelected(false);
                c_acoes.setEnabled(false);
            }

        }

        if (c_novelas.getState()) {
            try {
                listaNovelas = lerLista("Novela", "Pode ser qualquer novela/telenovela de qualquer canal de televisão.\nEx: A gata comeu.", "listaNovelas.dic");
                dicionarios.put(n_dicionariosAtivos++, listaNovelas);
            } catch (Exception ex) {
                //JOptionPane.showMessageDialog(this, "Um erro ocorreu ao ler o dicionário NOVELAS. O Dicinário não poderá ser usado.", "Erro ao carregar um dos dicionários", JOptionPane.WARNING_MESSAGE);
                c_novelas.setSelected(false);
                c_novelas.setEnabled(false);
            }

        }


        if (c_adjetivos.getState()) {
            try {
                listaAdjetivos = lerLista("Adjetivos", "Uma lista simples de adjetivos.\nEx: Neurótico.", "listaAdjetivos.dic");
                dicionarios.put(n_dicionariosAtivos++, listaAdjetivos);
            } catch (Exception ex) {
                //JOptionPane.showMessageDialog(this, "Um erro ocorreu ao ler o dicionário ADJETIVOS. O Dicinário não poderá ser usado.", "Erro ao carregar um dos dicionários", JOptionPane.WARNING_MESSAGE);
                c_adjetivos.setSelected(false);
                c_adjetivos.setEnabled(false);
            }

        }

        if (c_animais.getState()) {
            try {
                listaAnimais = lerLista("Animal", "A palavra é o nome de um animal.\nEx: Rola-Bosta.", "listaAnimais.dic");
                dicionarios.put(n_dicionariosAtivos++, listaAnimais);
            } catch (Exception ex) {
                //JOptionPane.showMessageDialog(this, "Um erro ocorreu ao ler o dicionário ANIMAIS. O Dicinário não poderá ser usado.", "Erro ao carregar um dos dicionários", JOptionPane.WARNING_MESSAGE);
                c_animais.setSelected(false);
                c_animais.setEnabled(false);
            }
        }

        if (c_criaturas.getState()) {

            try {
                listaCriaturas = lerLista("Criatura Mitológica", "Pode ser uma criatura mitológica/imaginária/Presente em Jogos.\nEx: Gárgula.", "listaCriaturas.dic");
                dicionarios.put(n_dicionariosAtivos++, listaCriaturas);
            } catch (Exception ex) {
                //JOptionPane.showMessageDialog(this, "Um erro ocorreu ao ler o dicionário CRIATURAS. O Dicinário não poderá ser usado.", "Erro ao carregar um dos dicionários", JOptionPane.WARNING_MESSAGE);
                c_criaturas.setSelected(false);
                c_criaturas.setEnabled(false);
            }
        }

        if (c_dificeis.getState()) {
            try {
                listaDificeis = lerLista("Dificil", "Pode ser qualquer palavras do portugues com suas derivações.\nExemplo: alfinetar-se-á.", "listaDificeis.dic");
                dicionarios.put(n_dicionariosAtivos++, listaDificeis);
            } catch (Exception ex) {
                //JOptionPane.showMessageDialog(this, "Um erro ocorreu ao ler o dicionário DIFICEIS. O Dicinário não poderá ser usado.", "Erro ao carregar um dos dicionários", JOptionPane.WARNING_MESSAGE);
                c_dificeis.setSelected(false);
                c_dificeis.setEnabled(false);
            }
        }


        if (c_esportes.getState()) {

            try {
                listaEsportes = lerLista("Esporte", "Pode ser qualquer esporte.\nEx: Esgrima.", "listaEsportes.dic");
                dicionarios.put(n_dicionariosAtivos++, listaEsportes);
            } catch (Exception ex) {
                //JOptionPane.showMessageDialog(this, "Um erro ocorreu ao ler o dicionário ESPORTES. O Dicinário não poderá ser usado.", "Erro ao carregar um dos dicionários", JOptionPane.WARNING_MESSAGE);
                c_esportes.setSelected(false);
                c_esportes.setEnabled(false);
            }

        }

        if (c_paises.getState()) {

            try {
                listaPaises = lerLista("País", "Pode ser qualquer páis do mundo.\nEx: Finlândia.", "listaPaises.dic");
                dicionarios.put(n_dicionariosAtivos++, listaPaises);
            } catch (Exception ex) {
                //JOptionPane.showMessageDialog(this, "Um erro ocorreu ao ler o dicionário PAÍSES. O Dicinário não poderá ser usado.", "Erro ao carregar um dos dicionários", JOptionPane.WARNING_MESSAGE);
                c_paises.setSelected(false);
                c_paises.setEnabled(false);
            }
        }

        if (c_nomes.getState()) {

            try {
                listaNomes = lerLista("Nome", "Pode ser o nome de qualquer coisa.\nUm Estado, um nome de pessoa, nome de cidade, etc.\nEx:Aquiles.", "listaNomes.dic");
                dicionarios.put(n_dicionariosAtivos++, listaNomes);
            } catch (Exception ex) {
                //JOptionPane.showMessageDialog(this, "Um erro ocorreu ao ler o dicionário NOMES. O Dicinário não poderá ser usado.", "Erro ao carregar um dos dicionários", JOptionPane.WARNING_MESSAGE);
                c_nomes.setSelected(false);
                c_nomes.setEnabled(false);
            }
        }


        if (c_qualquerPalavra.getState()) {
            try {
                listaQualquerPalavra = lerLista("Qualquer Palavra", "Qualquer palavra do português.\nExistem palavras dificeis e fáceis.\nExemplo: Perpendicular.", "listaQualquerPalavra.dic");
                dicionarios.put(n_dicionariosAtivos++, listaQualquerPalavra);
            } catch (Exception ex) {
                //JOptionPane.showMessageDialog(this, "Um erro ocorreu ao ler o dicionário QUALQUER PALAVRA. O Dicinário não poderá ser usado.", "Erro ao carregar um dos dicionários", JOptionPane.WARNING_MESSAGE);
                c_qualquerPalavra.setSelected(false);
                c_qualquerPalavra.setEnabled(false);
            }
        }
    }

    private void somTempoEsgotado() {
        if (c_som.getState()) {
            new AePlayWave("sons/tempoesgotado.wav").start();
        }
    }

    private void somViuPalavra() {
        if (c_som.getState() && !this.atual.equalsIgnoreCase("Nenhuma palavra foi sorteada!")) {
            new AePlayWave("sons/viupalavra.wav").start();
        }
    }

    private void somSorteouPalavra() {
        if (c_som.getState()) {
            new AePlayWave("sons/sorteoupalavra.wav").start();
        }
    }

    private void somIniciouCronometro() {
        if (c_som.getState()) {
            new AePlayWave("sons/inicioucronometro.wav").start();
        }
    }

    private void sortearPalavra() {
        Dicionario dic = dicionarios.get((Integer) Math.round((float) Math.random() * n_dicionariosAtivos));
        try {
            l_nome_dica.setText(dic.nome.trim());
            l_dica.setText(dic.dica.trim());
            String palavra = "";
            if (dic.palavras.size() > 0) {
                palavra = dic.palavras.get(Math.round((float) Math.random() * dic.palavras.size()));
            } else {
                sortearPalavra();
                return;
            }
            //l_palavra.setText("Passe o mouse para ver a palavra.");
            atual = palavra;
            janela.l_palavra.setForeground(new Color(255, 0, 0));
            janela.l_palavra.setText(atual);

            new Timer().schedule(new TimerTask() {

                public void run() {
                    janela.l_palavra.setForeground(new Color(0, 0, 0));
                    janela.l_palavra.setText("Passe o mouse para ver a palavra.");
                }
            }, 3000);

        } catch (Exception e) {
            sortearPalavra();
        }


        try {
            cronometro.purge();
            cronometro.cancel();
            cronometro = null;
            System.gc();
        } catch (Exception e) {
        }

        cronometro = cronometro = new Timer("Cronometro");
        time_atual = time;

        l_tempo.setText(formatador(time_atual));
//        try {
//            ajeitadicionarios();
//        } catch (Exception ex) {
//            ex.printStackTrace();
//        }
    }

    private Dicionario lerLista(String nome, String dica, String arquivo) throws FileNotFoundException, IOException {
        ArrayList<String> l = new ArrayList<String>();
        BufferedReader reader = new BufferedReader(new InputStreamReader(new FileInputStream("dicionarios/" + arquivo)));
        String line;
        while ((line = reader.readLine()) != null) {
            line = line.trim();
            if (line.equalsIgnoreCase("")) {
                continue;
            }
            l.add(line);
        }
        reader.close();
        return new Dicionario(nome, dica, l, arquivo);
    }

    @SuppressWarnings("unchecked")
    // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
    private void initComponents() {

        buttonGroup1 = new javax.swing.ButtonGroup();
        l_palavra = new javax.swing.JLabel();
        b_sortear = new javax.swing.JButton();
        p_cronometro = new javax.swing.JPanel();
        l_tempo = new javax.swing.JLabel();
        painel_dica = new javax.swing.JPanel();
        l_nome_dica = new javax.swing.JLabel();
        jScrollPane1 = new javax.swing.JScrollPane();
        l_dica = new javax.swing.JTextArea();
        b_iniciarDesenho = new javax.swing.JButton();
        jMenuBar1 = new javax.swing.JMenuBar();
        m_arquivo = new javax.swing.JMenu();
        i_fechar = new javax.swing.JMenuItem();
        m_config = new javax.swing.JMenu();
        m_dicionarios = new javax.swing.JMenu();
        c_animais = new javax.swing.JCheckBoxMenuItem();
        c_acoes = new javax.swing.JCheckBoxMenuItem();
        c_adjetivos = new javax.swing.JCheckBoxMenuItem();
        c_criaturas = new javax.swing.JCheckBoxMenuItem();
        c_dificeis = new javax.swing.JCheckBoxMenuItem();
        c_esportes = new javax.swing.JCheckBoxMenuItem();
        c_nomes = new javax.swing.JCheckBoxMenuItem();
        c_novelas = new javax.swing.JCheckBoxMenuItem();
        c_paises = new javax.swing.JCheckBoxMenuItem();
        c_qualquerPalavra = new javax.swing.JCheckBoxMenuItem();
        jSeparator3 = new javax.swing.JSeparator();
        m_tempo = new javax.swing.JMenu();
        te_30s = new javax.swing.JRadioButtonMenuItem();
        te_1m = new javax.swing.JRadioButtonMenuItem();
        te_1m30s = new javax.swing.JRadioButtonMenuItem();
        te_2m = new javax.swing.JRadioButtonMenuItem();
        te_3m = new javax.swing.JRadioButtonMenuItem();
        jSeparator4 = new javax.swing.JSeparator();
        c_som = new javax.swing.JCheckBoxMenuItem();
        c_dica = new javax.swing.JCheckBoxMenuItem();
        c_semprenotopo = new javax.swing.JCheckBoxMenuItem();
        m_ajuda = new javax.swing.JMenu();
        i_sobre = new javax.swing.JMenuItem();

        setDefaultCloseOperation(javax.swing.WindowConstants.EXIT_ON_CLOSE);
        setTitle("Desenhando");
        setAlwaysOnTop(true);
        setResizable(false);

        l_palavra.setFont(new java.awt.Font("Arial", 1, 18));
        l_palavra.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
        l_palavra.setText("Nenhuma palavra foi sorteada!");
        l_palavra.setBorder(javax.swing.BorderFactory.createTitledBorder("Palavra"));
        l_palavra.addMouseListener(new java.awt.event.MouseAdapter() {
            public void mouseEntered(java.awt.event.MouseEvent evt) {
                l_palavraMouseEntered(evt);
            }
            public void mouseExited(java.awt.event.MouseEvent evt) {
                l_palavraMouseExited(evt);
            }
        });

        b_sortear.setText("Sortear Palavra");
        b_sortear.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                b_sortearActionPerformed(evt);
            }
        });

        p_cronometro.setBorder(javax.swing.BorderFactory.createTitledBorder("Cronômetro"));

        l_tempo.setFont(new java.awt.Font("Arial", 0, 48));
        l_tempo.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
        l_tempo.setAlignmentX(0.5F);
        l_tempo.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);

        org.jdesktop.layout.GroupLayout p_cronometroLayout = new org.jdesktop.layout.GroupLayout(p_cronometro);
        p_cronometro.setLayout(p_cronometroLayout);
        p_cronometroLayout.setHorizontalGroup(
            p_cronometroLayout.createParallelGroup(org.jdesktop.layout.GroupLayout.LEADING)
            .add(org.jdesktop.layout.GroupLayout.TRAILING, p_cronometroLayout.createSequentialGroup()
                .addContainerGap()
                .add(l_tempo, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, 413, Short.MAX_VALUE)
                .addContainerGap())
        );
        p_cronometroLayout.setVerticalGroup(
            p_cronometroLayout.createParallelGroup(org.jdesktop.layout.GroupLayout.LEADING)
            .add(l_tempo, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, 89, Short.MAX_VALUE)
        );

        painel_dica.setBorder(javax.swing.BorderFactory.createTitledBorder("Dica"));

        l_nome_dica.setFont(new java.awt.Font("Arial", 1, 18));
        l_nome_dica.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);

        jScrollPane1.setEnabled(false);
        jScrollPane1.setOpaque(false);

        l_dica.setColumns(20);
        l_dica.setEditable(false);
        l_dica.setLineWrap(true);
        l_dica.setRows(3);
        l_dica.setWrapStyleWord(true);
        l_dica.setAutoscrolls(false);
        jScrollPane1.setViewportView(l_dica);

        org.jdesktop.layout.GroupLayout painel_dicaLayout = new org.jdesktop.layout.GroupLayout(painel_dica);
        painel_dica.setLayout(painel_dicaLayout);
        painel_dicaLayout.setHorizontalGroup(
            painel_dicaLayout.createParallelGroup(org.jdesktop.layout.GroupLayout.LEADING)
            .add(org.jdesktop.layout.GroupLayout.TRAILING, painel_dicaLayout.createSequentialGroup()
                .addContainerGap()
                .add(painel_dicaLayout.createParallelGroup(org.jdesktop.layout.GroupLayout.TRAILING)
                    .add(org.jdesktop.layout.GroupLayout.LEADING, jScrollPane1, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, 413, Short.MAX_VALUE)
                    .add(org.jdesktop.layout.GroupLayout.LEADING, l_nome_dica, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, 413, Short.MAX_VALUE))
                .addContainerGap())
        );
        painel_dicaLayout.setVerticalGroup(
            painel_dicaLayout.createParallelGroup(org.jdesktop.layout.GroupLayout.LEADING)
            .add(painel_dicaLayout.createSequentialGroup()
                .add(l_nome_dica, org.jdesktop.layout.GroupLayout.PREFERRED_SIZE, 30, org.jdesktop.layout.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(org.jdesktop.layout.LayoutStyle.RELATED)
                .add(jScrollPane1, org.jdesktop.layout.GroupLayout.PREFERRED_SIZE, 75, org.jdesktop.layout.GroupLayout.PREFERRED_SIZE)
                .addContainerGap())
        );

        b_iniciarDesenho.setText("Iniciar Desenho");
        b_iniciarDesenho.setEnabled(false);
        b_iniciarDesenho.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                b_iniciarDesenhoActionPerformed(evt);
            }
        });
        b_iniciarDesenho.addMouseListener(new java.awt.event.MouseAdapter() {
            public void mouseClicked(java.awt.event.MouseEvent evt) {
                b_iniciarDesenhoMouseClicked(evt);
            }
        });

        m_arquivo.setText("Arquivo");

        i_fechar.setAccelerator(javax.swing.KeyStroke.getKeyStroke(java.awt.event.KeyEvent.VK_F4, java.awt.event.InputEvent.ALT_MASK));
        i_fechar.setText("Fechar");
        i_fechar.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                i_fecharActionPerformed(evt);
            }
        });
        m_arquivo.add(i_fechar);

        jMenuBar1.add(m_arquivo);

        m_config.setText("Configurações");

        m_dicionarios.setText("Dicionarios");

        c_animais.setSelected(true);
        c_animais.setText("Animais");
        c_animais.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                c_animaisActionPerformed(evt);
            }
        });
        m_dicionarios.add(c_animais);

        c_acoes.setSelected(true);
        c_acoes.setText("Ações");
        c_acoes.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                c_acoesActionPerformed(evt);
            }
        });
        m_dicionarios.add(c_acoes);

        c_adjetivos.setSelected(true);
        c_adjetivos.setText("Adjetivos");
        c_adjetivos.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                c_adjetivosActionPerformed(evt);
            }
        });
        m_dicionarios.add(c_adjetivos);

        c_criaturas.setSelected(true);
        c_criaturas.setText("Criaturas Lendárias");
        c_criaturas.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                c_criaturasActionPerformed(evt);
            }
        });
        m_dicionarios.add(c_criaturas);

        c_dificeis.setSelected(true);
        c_dificeis.setText("Difícil");
        c_dificeis.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                c_dificeisActionPerformed(evt);
            }
        });
        m_dicionarios.add(c_dificeis);

        c_esportes.setSelected(true);
        c_esportes.setText("Esportes");
        m_dicionarios.add(c_esportes);

        c_nomes.setSelected(true);
        c_nomes.setText("Nomes");
        m_dicionarios.add(c_nomes);

        c_novelas.setSelected(true);
        c_novelas.setText("Novelas");
        m_dicionarios.add(c_novelas);

        c_paises.setSelected(true);
        c_paises.setText("Países");
        c_paises.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                c_paisesActionPerformed(evt);
            }
        });
        m_dicionarios.add(c_paises);

        c_qualquerPalavra.setSelected(true);
        c_qualquerPalavra.setText("Qualquer Palavra");
        c_qualquerPalavra.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                c_qualquerPalavraActionPerformed(evt);
            }
        });
        m_dicionarios.add(c_qualquerPalavra);

        m_config.add(m_dicionarios);
        m_config.add(jSeparator3);

        m_tempo.setText("Tempo");

        buttonGroup1.add(te_30s);
        te_30s.setText("30 seg");
        te_30s.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                te_30sActionPerformed(evt);
            }
        });
        m_tempo.add(te_30s);

        buttonGroup1.add(te_1m);
        te_1m.setSelected(true);
        te_1m.setText("1 min");
        te_1m.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                te_1mActionPerformed(evt);
            }
        });
        m_tempo.add(te_1m);

        buttonGroup1.add(te_1m30s);
        te_1m30s.setText("1 min 30 s");
        te_1m30s.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                te_1m30sActionPerformed(evt);
            }
        });
        m_tempo.add(te_1m30s);

        buttonGroup1.add(te_2m);
        te_2m.setText("2 min");
        te_2m.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                te_2mActionPerformed(evt);
            }
        });
        m_tempo.add(te_2m);

        buttonGroup1.add(te_3m);
        te_3m.setText("3 min");
        te_3m.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                te_3mActionPerformed(evt);
            }
        });
        m_tempo.add(te_3m);

        m_config.add(m_tempo);
        m_config.add(jSeparator4);

        c_som.setSelected(true);
        c_som.setText("Habilitar Som");
        m_config.add(c_som);

        c_dica.setSelected(true);
        c_dica.setText("Mostrar Dica");
        c_dica.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                c_dicaActionPerformed(evt);
            }
        });
        m_config.add(c_dica);

        c_semprenotopo.setSelected(true);
        c_semprenotopo.setText("Sempre no topo");
        c_semprenotopo.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                c_semprenotopoActionPerformed(evt);
            }
        });
        m_config.add(c_semprenotopo);

        jMenuBar1.add(m_config);

        m_ajuda.setText("Ajuda");

        i_sobre.setAccelerator(javax.swing.KeyStroke.getKeyStroke(java.awt.event.KeyEvent.VK_F1, 0));
        i_sobre.setText("Sobre");
        i_sobre.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                i_sobreActionPerformed(evt);
            }
        });
        m_ajuda.add(i_sobre);

        jMenuBar1.add(m_ajuda);

        setJMenuBar(jMenuBar1);

        org.jdesktop.layout.GroupLayout layout = new org.jdesktop.layout.GroupLayout(getContentPane());
        getContentPane().setLayout(layout);
        layout.setHorizontalGroup(
            layout.createParallelGroup(org.jdesktop.layout.GroupLayout.LEADING)
            .add(layout.createSequentialGroup()
                .addContainerGap()
                .add(layout.createParallelGroup(org.jdesktop.layout.GroupLayout.LEADING)
                    .add(b_sortear, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, 445, Short.MAX_VALUE)
                    .add(org.jdesktop.layout.GroupLayout.TRAILING, l_palavra, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, 445, Short.MAX_VALUE)
                    .add(org.jdesktop.layout.GroupLayout.TRAILING, p_cronometro, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .add(painel_dica, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .add(b_iniciarDesenho, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, 445, Short.MAX_VALUE))
                .addContainerGap())
        );
        layout.setVerticalGroup(
            layout.createParallelGroup(org.jdesktop.layout.GroupLayout.LEADING)
            .add(layout.createSequentialGroup()
                .addContainerGap()
                .add(p_cronometro, org.jdesktop.layout.GroupLayout.PREFERRED_SIZE, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, org.jdesktop.layout.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(org.jdesktop.layout.LayoutStyle.RELATED)
                .add(l_palavra, org.jdesktop.layout.GroupLayout.PREFERRED_SIZE, 102, org.jdesktop.layout.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(org.jdesktop.layout.LayoutStyle.UNRELATED)
                .add(painel_dica, org.jdesktop.layout.GroupLayout.PREFERRED_SIZE, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, org.jdesktop.layout.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(org.jdesktop.layout.LayoutStyle.RELATED)
                .add(b_sortear, org.jdesktop.layout.GroupLayout.PREFERRED_SIZE, 34, org.jdesktop.layout.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(org.jdesktop.layout.LayoutStyle.RELATED)
                .add(b_iniciarDesenho, org.jdesktop.layout.GroupLayout.PREFERRED_SIZE, 34, org.jdesktop.layout.GroupLayout.PREFERRED_SIZE)
                .addContainerGap(org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );

        pack();
    }// </editor-fold>//GEN-END:initComponents
    private void b_sortearActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_b_sortearActionPerformed
        sortearPalavra();
        somSorteouPalavra();
        b_iniciarDesenho.setEnabled(true);
        sorteou = true;
}//GEN-LAST:event_b_sortearActionPerformed

    private void c_animaisActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_c_animaisActionPerformed
        lerDicionarios();
    }//GEN-LAST:event_c_animaisActionPerformed

    private void c_acoesActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_c_acoesActionPerformed
        lerDicionarios();
    }//GEN-LAST:event_c_acoesActionPerformed

    private void c_adjetivosActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_c_adjetivosActionPerformed
        lerDicionarios();
    }//GEN-LAST:event_c_adjetivosActionPerformed

    private void c_criaturasActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_c_criaturasActionPerformed
        lerDicionarios();
    }//GEN-LAST:event_c_criaturasActionPerformed

    private void c_paisesActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_c_paisesActionPerformed
        lerDicionarios();
    }//GEN-LAST:event_c_paisesActionPerformed

    private void c_qualquerPalavraActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_c_qualquerPalavraActionPerformed
        lerDicionarios();
}//GEN-LAST:event_c_qualquerPalavraActionPerformed

    private void c_dificeisActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_c_dificeisActionPerformed
        lerDicionarios();
}//GEN-LAST:event_c_dificeisActionPerformed

    private void i_fecharActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_i_fecharActionPerformed
        if (JOptionPane.showConfirmDialog(this, "Tem certeza que deseja sair do programa?", "Deseja sair do programa?", JOptionPane.YES_NO_OPTION, JOptionPane.QUESTION_MESSAGE) == 0) {
            System.exit(0);
        }
    }//GEN-LAST:event_i_fecharActionPerformed

    private void l_palavraMouseExited(java.awt.event.MouseEvent evt) {//GEN-FIRST:event_l_palavraMouseExited
        if (sorteou) {
            janela.l_palavra.setForeground(new Color(0, 0, 0));
            l_palavra.setText("Passe o mouse para ver a palavra.");
        }
    }//GEN-LAST:event_l_palavraMouseExited

    private void l_palavraMouseEntered(java.awt.event.MouseEvent evt) {//GEN-FIRST:event_l_palavraMouseEntered
        if (sorteou) {
            janela.l_palavra.setForeground(new Color(255, 0, 0));
            l_palavra.setText(atual);
            somViuPalavra();
        }
    }//GEN-LAST:event_l_palavraMouseEntered

    private void te_30sActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_te_30sActionPerformed
        time = 30;
        time_atual = time;
        l_tempo.setText(formatador(time_atual));
}//GEN-LAST:event_te_30sActionPerformed

    private void te_1mActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_te_1mActionPerformed
        time = 60;
        time_atual = time;
        l_tempo.setText(formatador(time_atual));
}//GEN-LAST:event_te_1mActionPerformed

    private void te_1m30sActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_te_1m30sActionPerformed
        time = 90;
        time_atual = time;
        l_tempo.setText(formatador(time_atual));
}//GEN-LAST:event_te_1m30sActionPerformed

    private void te_2mActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_te_2mActionPerformed
        time = 120;
        time_atual = time;
        l_tempo.setText(formatador(time_atual));
    }//GEN-LAST:event_te_2mActionPerformed

    private void te_3mActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_te_3mActionPerformed
        time = 180;
        time_atual = time;
        l_tempo.setText(formatador(time_atual));
    }//GEN-LAST:event_te_3mActionPerformed

    private void c_semprenotopoActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_c_semprenotopoActionPerformed
        this.setAlwaysOnTop(c_semprenotopo.getState());
    }//GEN-LAST:event_c_semprenotopoActionPerformed

    private void c_dicaActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_c_dicaActionPerformed
        painel_dica.setVisible(c_dica.getState());

        if (c_dica.getState()) {
            this.setSize(new Dimension(470, 525));
        } else {
            this.setSize(new Dimension(470, 380));
        }
    }//GEN-LAST:event_c_dicaActionPerformed

    private void b_iniciarDesenhoMouseClicked(java.awt.event.MouseEvent evt) {//GEN-FIRST:event_b_iniciarDesenhoMouseClicked
    }//GEN-LAST:event_b_iniciarDesenhoMouseClicked

    private void b_iniciarDesenhoActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_b_iniciarDesenhoActionPerformed
        iniciarCronometro();
        somIniciouCronometro();
    }//GEN-LAST:event_b_iniciarDesenhoActionPerformed

    private void i_sobreActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_i_sobreActionPerformed
        JanelaSobre sobre = new JanelaSobre();
        sobre.setAlwaysOnTop(true);
        sobre.setLocationRelativeTo(this);
        sobre.setVisible(true);

    }//GEN-LAST:event_i_sobreActionPerformed

    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JButton b_iniciarDesenho;
    private javax.swing.JButton b_sortear;
    private javax.swing.ButtonGroup buttonGroup1;
    private javax.swing.JCheckBoxMenuItem c_acoes;
    private javax.swing.JCheckBoxMenuItem c_adjetivos;
    private javax.swing.JCheckBoxMenuItem c_animais;
    private javax.swing.JCheckBoxMenuItem c_criaturas;
    private javax.swing.JCheckBoxMenuItem c_dica;
    private javax.swing.JCheckBoxMenuItem c_dificeis;
    private javax.swing.JCheckBoxMenuItem c_esportes;
    private javax.swing.JCheckBoxMenuItem c_nomes;
    private javax.swing.JCheckBoxMenuItem c_novelas;
    private javax.swing.JCheckBoxMenuItem c_paises;
    private javax.swing.JCheckBoxMenuItem c_qualquerPalavra;
    private javax.swing.JCheckBoxMenuItem c_semprenotopo;
    private javax.swing.JCheckBoxMenuItem c_som;
    private javax.swing.JMenuItem i_fechar;
    private javax.swing.JMenuItem i_sobre;
    private javax.swing.JMenuBar jMenuBar1;
    private javax.swing.JScrollPane jScrollPane1;
    private javax.swing.JSeparator jSeparator3;
    private javax.swing.JSeparator jSeparator4;
    private javax.swing.JTextArea l_dica;
    private javax.swing.JLabel l_nome_dica;
    private javax.swing.JLabel l_palavra;
    private javax.swing.JLabel l_tempo;
    private javax.swing.JMenu m_ajuda;
    private javax.swing.JMenu m_arquivo;
    private javax.swing.JMenu m_config;
    private javax.swing.JMenu m_dicionarios;
    private javax.swing.JMenu m_tempo;
    private javax.swing.JPanel p_cronometro;
    private javax.swing.JPanel painel_dica;
    private javax.swing.JRadioButtonMenuItem te_1m;
    private javax.swing.JRadioButtonMenuItem te_1m30s;
    private javax.swing.JRadioButtonMenuItem te_2m;
    private javax.swing.JRadioButtonMenuItem te_30s;
    private javax.swing.JRadioButtonMenuItem te_3m;
    // End of variables declaration//GEN-END:variables

    class Dicionario {

        ArrayList<String> palavras;
        String nome;
        String dica;
        String arquivo;

        private Dicionario(String nome, String dica, ArrayList<String> palavras, String arquivo) {
            this.nome = nome;
            this.dica = dica;
            this.palavras = palavras;
            this.arquivo = arquivo;
        }
    }
}
