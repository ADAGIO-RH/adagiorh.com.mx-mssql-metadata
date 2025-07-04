USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Nomina].[spBorrarLayoutPago]  
(  
 @IDLayoutPago int,
 @IDUsuario int   
)  
AS  
BEGIN  
 	declare 
		@OldJSON Varchar(Max) = '',
		@OldJSON2 Varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[spBorrarLayoutPago]',
		@Tabla		varchar(max) = '[Nomina].[tblLayoutPago]',
		@Accion		varchar(20)	= 'DELETE'
	;

	exec [Nomina].[spBuscarLayoutPago]  @IDLayoutPago  

	select @OldJSON = a.JSON 
	from (
		SELECT       
			lp.IDLayoutPago    
			,lp.Descripcion     
			,tlp.IDTipoLayout        
			,tlp.TipoLayout          
			,ISNULL(lp.IDConcepto,0) as IDConcepto        
			,cc.Descripcion as Concepto    
			,lp.ImporteTotal 
			,ISNULL(lp.IDConceptoFiniquito,0) as IDConceptoFiniquito        
			,CCF.Descripcion as ConceptoFiniquito    
			,isnull(lp.ImporteTotalFiniquito,0) as ImporteTotalFiniquito    
			,ROW_NUMBER()over(order by IDLayoutPago asc) as ROWNUMBER        
		FROM Nomina.tblLayoutPago Lp with(nolock)      
			left join [Nomina].[tblCatTiposLayout] tlp  with(nolock)
				on lp.IDTipoLayout = tlp.IDTipoLayout     
			Left Join Sat.tblCatBancos B with(nolock)        
				on tlp.IDBanco = B.IDBanco      
			left join Nomina.tblcatconceptos CC with(nolock)    
				on lp.IDConcepto = cc.IDConcepto      
			left join Nomina.tblcatconceptos CCF with(nolock)
				on lp.IDConceptoFiniquito = CCF.IDConcepto
	  WHERE (LP.IDLayoutPago = @IDLayoutPago)
	) b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
	
	 SELECT @OldJSON2 ='['+ STUFF(
            ( select ','+ a.JSON
							from Nomina.tblLayoutPagoParametros b
							Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
												FOR xml path('')
            )
            , 1
            , 1
            , ''
	)+']'

	delete Nomina.tblLayoutPagoParametros  
	where IDLayoutPago = @IDLayoutPago  

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= ''
		,@OldData		= @OldJSON2 
  
	delete Nomina.tblLayoutPago  
	where IDLayoutPago = @IDLayoutPago 
	
	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= ''
		,@OldData		= @OldJSON 

  
END
GO
