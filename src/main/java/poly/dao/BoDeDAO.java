package poly.dao;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import poly.model.BoDe;

@Repository
public class BoDeDAO {

	@Autowired
	JdbcTemplate db;

	public List<BoDe> findByFilterPaged(String maMH, String trinhDo, String maGV, String noiDung, String maGVLoc,
			int page, int pageSize) {
		String maMHParam = (maMH != null && !maMH.isEmpty()) ? maMH : null;
		String trinhDoParam = (trinhDo != null && !trinhDo.isEmpty()) ? trinhDo : null;
		String maGVParam = (maGV != null && !maGV.isEmpty()) ? maGV : null;
		String noiDungParam = (noiDung != null && !noiDung.isEmpty()) ? noiDung : null;
		String maGVLocParam = (maGVLoc != null && !maGVLoc.isEmpty()) ? maGVLoc : null;

		return db.query("EXEC SP_BODE_GETPAGED ?, ?, ?, ?, ?, ?, ?", new BeanPropertyRowMapper<>(BoDe.class), maMHParam,
				trinhDoParam, maGVParam, noiDungParam, maGVLocParam, page, pageSize);
	}

	public int countByFilter(String maMH, String trinhDo, String maGV, String noiDung, String maGVLoc) {
		String maMHParam = (maMH != null && !maMH.isEmpty()) ? maMH : null;
		String trinhDoParam = (trinhDo != null && !trinhDo.isEmpty()) ? trinhDo : null;
		String maGVParam = (maGV != null && !maGV.isEmpty()) ? maGV : null;
		String noiDungParam = (noiDung != null && !noiDung.isEmpty()) ? noiDung : null;
		String maGVLocParam = (maGVLoc != null && !maGVLoc.isEmpty()) ? maGVLoc : null;

		return db.queryForObject("EXEC SP_BODE_COUNT ?, ?, ?, ?, ?", Integer.class, maMHParam, trinhDoParam, maGVParam,
				noiDungParam, maGVLocParam);
	}

	public BoDe findByCauHoi(int cauHoi) {
		List<BoDe> list = db.query("EXEC SP_BODE_GETBYID ?", new BeanPropertyRowMapper<>(BoDe.class), cauHoi);
		return list.isEmpty() ? null : list.get(0);
	}

	public void insert(BoDe bd) {
		db.update("EXEC SP_BODE_INSERT ?, ?, ?, ?, ?, ?, ?, ?, ?", bd.getMaMH(), bd.getTrinhDo(), bd.getNoiDung(),
				bd.getA(), bd.getB(), bd.getC(), bd.getD(), bd.getDapAn(), bd.getMaGV());
	}

	public void update(BoDe bd) {
		db.update("EXEC SP_BODE_UPDATE ?, ?, ?, ?, ?, ?, ?", bd.getCauHoi(), bd.getNoiDung(), bd.getA(), bd.getB(),
				bd.getC(), bd.getD(), bd.getDapAn());
	}

	public void delete(int cauHoi) {
		db.update("EXEC SP_BODE_DELETE ?", cauHoi);
	}

	public int demSoCau(String maMH, String trinhDo) {
		return db.queryForObject("EXEC SP_BODE_DEMSOCAU ?, ?", Integer.class, maMH, trinhDo);
	}
	
	public boolean daSuDung(int cauHoi) {
	    int result = db.queryForObject("EXEC SP_BODE_KIEMTRA_DASUDUNG ?", Integer.class, cauHoi);
	    return result == 1;
	}
}