USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spUICapturaDetallePeriodoSheetsGeneral]        
(    
	@IDUsuario int,
	@DetallePeriodoCapturaGeneral [Nomina].[dtDetallePeriodoCapturaGeneral] READONLY        
)        
AS        
BEGIN    
	declare 
		@IDPeriodo int
	;
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[spUICapturaDetallePeriodoSheetsGeneral]',
		@Tabla		varchar(max) = '[Nomina].[tblDetallePeriodo]',
		@Accion		varchar(20)		= 'IMPORTAR CAPTURAS',
		@Mensaje	varchar(max),
		@InformacionExtra	varchar(max)
	;
	select top 1 @IDPeriodo = IDPeriodo from @DetallePeriodoCapturaGeneral

	select @NewJSON = a.JSON
	from Nomina.tblCatPeriodos b with (nolock)
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.IDPeriodo,b.ClavePeriodo,b.Descripcion  For XML Raw)) ) a
	where IDPeriodo = @IDPeriodo

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON
		,@Mensaje		= @Mensaje
		,@InformacionExtra		= @InformacionExtra

	declare @DetallePeriodoCapturaGeneral2 [Nomina].[dtDetallePeriodoCapturaGeneral]      
       
	insert into @DetallePeriodoCapturaGeneral2
	select * from @DetallePeriodoCapturaGeneral

	update @DetallePeriodoCapturaGeneral2
	set IDReferencia = CASE WHEN IDReferencia = 0 THEN null ELSE IDReferencia END
        
	MERGE Nomina.tblDetallePeriodo AS TARGET        
	USING @DetallePeriodoCapturaGeneral2 AS SOURCE        
		ON (TARGET.IDConcepto = SOURCE.IDConcepto         
				and TARGET.IDEmpleado = SOURCE.IDEmpleado        
				and TARGET.IDPeriodo = SOURCE.IDPeriodo      
				and isnull(TARGET.IDReferencia,0) = isnull(SOURCE.IDReferencia,0)     
			 )        
    WHEN MATCHED Then        
		update        
			Set             
				 TARGET.CantidadMonto  =  CASE WHEN (ISNULL(SOURCE.CantidadMonto,0)<>0)THEN  isnull(SOURCE.CantidadMonto,0) ELSE 0 END        
				,TARGET.CantidadDias   =  CASE WHEN (ISNULL(SOURCE.CantidadDias,0)<>0) THEN  isnull(SOURCE.CantidadDias,0)  ELSE 0 END        
				,TARGET.CantidadVeces  =  CASE WHEN (ISNULL(SOURCE.CantidadVeces,0)<>0)THEN  isnull(SOURCE.CantidadVeces,0) ELSE 0 END        
				,TARGET.CantidadOtro1  =  CASE WHEN (ISNULL(SOURCE.CantidadOtro1,0)<>0)THEN  isnull(SOURCE.CantidadOtro1,0) ELSE 0 END        
				,TARGET.CantidadOtro2  =  CASE WHEN (ISNULL(SOURCE.CantidadOtro2,0)<>0)THEN  isnull(SOURCE.CantidadOtro2,0) ELSE 0 END        
				,TARGET.IDReferencia = CASE WHEN SOURCE.IDReferencia = 0 THEN null ELSE SOURCE.IDReferencia END        
            
    WHEN NOT MATCHED BY TARGET THEN         
		INSERT(IDEmpleado,IDPeriodo,IDConcepto,CantidadMonto,CantidadDias,CantidadVeces,CantidadOtro1,CantidadOtro2, IDReferencia)        
		VALUES(SOURCE.IDEmpleado,SOURCE.IDPeriodo,SOURCE.IDConcepto        
		,CASE WHEN (ISNULL(SOURCE.CantidadMonto,0)<>0)THEN isnull(SOURCE.CantidadMonto,0) ELSE 0 END         
		,CASE WHEN (ISNULL(SOURCE.CantidadDias,0)<>0) THEN isnull(SOURCE.CantidadDias,0)  ELSE 0 END         
		,CASE WHEN (ISNULL(SOURCE.CantidadVeces,0)<>0)THEN isnull(SOURCE.CantidadVeces,0) ELSE 0 END         
		,CASE WHEN (ISNULL(SOURCE.CantidadOtro1,0)<>0)THEN isnull(SOURCE.CantidadOtro1,0) ELSE 0 END         
		,CASE WHEN (ISNULL(SOURCE.CantidadOtro2,0)<>0)THEN isnull(SOURCE.CantidadOtro2,0) ELSE 0 END  
		,CASE WHEN SOURCE.IDReferencia = 0 THEN null ELSE SOURCE.IDReferencia END        
		);      
END
GO
