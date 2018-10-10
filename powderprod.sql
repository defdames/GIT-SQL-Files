SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







Alter    view [dbo].[powderprod]
AS
    select distinct
        ugroup ='1' ,
        A.pm_shop_key,
        A.gl_cmp_key,
        A.sf_plant_key,
        A.pm_shop_stat,
        E.sf_ingrd_key item,
        A.pm_shop_bqty,
        A.pm_shop_buom,
        A.pm_shop_stdt,
        B.sf_ingrd_key,
        B.pm_matl_uom,
        pm_matl_issqt = B.pm_matl_issqt - B.pm_matl_retqt,
        B.pm_matl_retqt,
        in_tran_ordtp = C.in_lottr_ordtp,
        C.in_lot_key 'lot_key_tran_tbl',
        in_tran_entid = C.in_lottr_entid,
        /*in_tran_qty =  case when C.in_lot_key is null
				then case when B.im_pack_key = ' '
					then isnull(B.pm_matl_issqt,0) - isnull(B.pm_matl_retqt,0)
					else (isnull(B.pm_matl_issqt * L.im_pack_qty,0)) - (ISNULL(B.pm_matl_retqt,0) * L.im_pack_qty)
				     end
				else case when C.im_pack_key = ' '
					then isnull(C.in_lottr_qty,0) - isnull(I.in_tran_qty,0)
					else (isnull(C.in_lottr_qty * J.im_pack_qty,0)) - (ISNULL(I.in_tran_qty,0) *J.im_pack_qty) 
		      		     end
		     end,
		*/
        in_tran_qty =  case when C.in_lot_key is null
				then case when B.im_pack_key = ' '
					then DBO.CONVERSION((isnull(B.pm_matl_issqt,0) - isnull(B.pm_matl_retqt,0)),L.IM_PACK_UOM,B.PM_MATL_UOM,1)
					else DBO.CONVERSION((isnull(B.pm_matl_issqt * L.im_pack_qty,0)) - (ISNULL(B.pm_matl_retqt,0) * L.im_pack_qty),L.IM_PACK_UOM,B.PM_MATL_UOM,1)
				     end
				else case when C.im_pack_key = ' '
					then  isnull(C.in_lottr_qty,0) - isnull(I.in_tran_qty,0)  --Revision by DAD on 01/12/2016
					else DBO.CONVERSION((isnull(C.in_lottr_qty * J.im_pack_qty,0)) - (ISNULL(I.in_tran_qty,0) *J.im_pack_qty),J.IM_PACK_UOM,B.PM_MATL_UOM,1)
		      		     end
		     end,
        G.in_desc,
        E.pm_lot_qty,
        E.in_lot_key,
        F.en_item_desc,
        H.ad_press_key,
        H.ac_mills_key,
        H.ae_grindhrs_key,
        H.af_millhrs_key,
        H.ag_compressor_key,
        H.ah_air_key,
        H.an_dumps_key,
        H.aa_initials_key,
        H.ab_system_key 'idgdout_syskey',
        H.ao_pressure_key,
        H.ap_pressure_key,
        H.aq_pressure_key,
        H.ar_recvarwash_key
    from pm_shop_tbl		 A
        --join    	 pm_matl_tbl 		 B  on A.pm_shop_key = B.pm_shop_key 
        --and					       A.gl_cmp_key  = B.gl_cmp_key 
        --and					       A.sf_plant_key = B.sf_plant_key 

        join pm_matl_SUM        	 B on A.pm_shop_key = B.pm_shop_key
            and A.sf_plant_key = B.sf_plant_key
            AND A.gl_cmp_key = B.gl_cmp_key

        left outer join millprod_lottr_sum	 C on B.sf_ingrd_key = C.in_item_key
            and B.gl_cmp_key   = C.gl_cmp_key
            and B.in_whs_key   = C.in_whs_key
            and B.pm_shop_key  = C.in_lottr_ordid
        join in_item_tbl 		 D on	A.in_item_key = D.in_item_key
            AND A.gl_cmp_key = D.gl_cmp_key
        join pm_lot_tbl  		 E on	A.sf_plant_key =  E.sf_plant_key
            and A.pm_shop_key = E.pm_shop_key
            and A.gl_cmp_key = E.gl_cmp_key
            and e.pm_lot_qty > '0'

        join en_item_tbl 		 F on	B.sf_ingrd_key = F.en_item_key
        join in_item_tbl 		 G on  E.sf_ingrd_key = G.in_item_key
            AND A.gl_cmp_key   = G.gl_cmp_key
        left outer join pm_igdout_ext 		 H on	E.gl_cmp_key = H.gl_cmp_key
            and E.sf_plant_key = H.sf_plant_key
            and E.pm_shop_key = H.pm_shop_key
            and E.sf_ingrd_key = H.sf_ingrd_key
            and E.sf_opseq_key = H.sf_opseq_key
        --left outer join  in_tran_tbl   		 I  on  C.in_item_key  = I.in_item_key 
        --and     					C.gl_cmp_key   = I.gl_cmp_key 
        --and      					C.in_whs_key   = I.in_whs_key
        --and						C.im_pack_key  = I.im_pack_key
        --and						C.in_lot_key   = I.in_lot_key
        --and     					C.in_lottr_ordid = I.in_tran_ordid 
        --and      							  I.in_tran_ordtp = 'B' 
        --and     							  I.in_tran_type = 'R'
        left outer join lot_tran_sum   		 I on  C.in_item_key  = I.in_item_key
            and C.in_whs_key   = I.in_whs_key
            and C.im_pack_key  = I.im_pack_key
            and C.in_lot_key   = I.in_lot_key
            and c.gl_cmp_key = I.gl_cmp_key

            and C.in_lottr_ordid = I.in_tran_demandid

        left outer join im_pack_tbl		 J on	C.im_pack_key =   J.im_pack_key
        left outer join im_pack_tbl		 K on	I.im_pack_key =	  K.im_pack_key
        left outer join im_pack_tbl		 L on	B.im_pack_key =   L.im_pack_key

    where 
      --A.pm_shop_stat = 3 and  /* print all shop orders regardless of status per CM on 10/18/99 */
       G.in_item_key like 'RM%'

