import javax.swing.UIManager;
 
class ShowMainPlafs {
 
    public static void main(String[] args) {
        UIManager.LookAndFeelInfo[] lafis = UIManager.getInstalledLookAndFeels();
        for (UIManager.LookAndFeelInfo lafi : lafis) {
            System.out.println(lafi);
        }
        System.out.println( System.getProperty("os.name") );
        System.out.println( System.getProperty("java.vendor") );
        System.out.println( System.getProperty("java.version") );
    }
}

