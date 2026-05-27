// 初期設定
trans = 0.75 ;  // 透明度
$fn = 50 ;      // 円や円柱をなめらかに表示

// 局舎を描画する
color("Gray",trans) {
	cube([9,9,4]);
}

// 鉄塔を描画する
color("White",trans) {
	translate([2.5,2.5,4]) {
		cylinder(h=15,r=0.25) ;
	}
	translate([6.5,2.5,4]) {
		cylinder(h=15,r=0.25) ;
	}
	translate([2.5,6.5,4]) {
		cylinder(h=15,r=0.25) ;
	}
	translate([6.5,6.5,4]) {
		cylinder(h=15,r=0.25) ;
	}
}

// プラットホームを描画する
color("Red",trans) {
	translate([4.5,4.5,11]) {
		cylinder(h=0.5,r=4) ;
	}
	translate([4.5,4.5,14]) {
		cylinder(h=0.5,r=4) ;
	}
	translate([4.5,4.5,17]) {
		cylinder(h=0.5,r=4) ;
	}
}

// パラボラアンテナを描画する
color("White",100) {
	translate([4.5,2.5,12.5]) {
		rotate([120,90,0]) { 
			cylinder(h=0.25,r=1) ;
		}
	}
	translate([4.5,2.5,18.5]) {
		rotate([120,90,0]) { 
			cylinder(h=0.25,r=1) ;
		}
	}
}
