USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spUICapturaDetallePeriodoSheetsGeneralFiniquito]        
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
		@NombreSP	varchar(max) = '[Nomina].[spUICapturaDetallePeriodoSheetsGeneralFiniquito]',
		@Tabla		varchar(max) = '[Nomina].[tblDetallePeriodoFiniquito]',
		@Accion		varchar(20)		= 'IMPORTAR CAPTURAS FINIQUITO',
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
  
	MERGE Nomina.tblDetallePeriodoFiniquito AS TARGET        
    USING @DetallePeriodoCapturaGeneral2 AS SOURCE        
		ON TARGET.IDConcepto = SOURCE.IDConcepto         
		and TARGET.IDEmpleado = SOURCE.IDEmpleado        
		and TARGET.IDPeriodo = SOURCE.IDPeriodo 
		and isnull(TARGET.IDReferencia,0) = isnull(SOURCE.IDReferencia,0)          
    WHEN MATCHED Then        
    update        
		Set             
			 TARGET.CantidadMonto  = CASE WHEN (ISNULL(SOURCE.CantidadMonto,0)>0)THEN SOURCE.CantidadMonto ELSE CASE WHEN (ISNULL(SOURCE.CantidadMonto,0) = -1) THEN -1 ELSE 0 END END        
			,TARGET.CantidadDias   = CASE WHEN (ISNULL(SOURCE.CantidadDias,0)>0)THEN SOURCE.CantidadDias ELSE   CASE WHEN (ISNULL(SOURCE.CantidadDias,0) = -1) THEN -1 ELSE 0 END END        
			,TARGET.CantidadVeces  = CASE WHEN (ISNULL(SOURCE.CantidadVeces,0)>0)THEN SOURCE.CantidadVeces ELSE CASE WHEN (ISNULL(SOURCE.CantidadVeces,0) = -1) THEN -1 ELSE 0 END END        
			,TARGET.CantidadOtro1  = CASE WHEN (ISNULL(SOURCE.CantidadOtro1,0)>0)THEN SOURCE.CantidadOtro1 ELSE CASE WHEN (ISNULL(SOURCE.CantidadOtro1,0) = -1) THEN -1 ELSE 0 END END        
			,TARGET.CantidadOtro2  = CASE WHEN (ISNULL(SOURCE.CantidadOtro2,0)>0)THEN SOURCE.CantidadOtro2 ELSE CASE WHEN (ISNULL(SOURCE.CantidadOtro2,0) = -1) THEN -1 ELSE 0 END END        
			,TARGET.IDReferencia = CASE WHEN SOURCE.IDReferencia = 0 THEN null ELSE SOURCE.IDReferencia END    
            
		WHEN NOT MATCHED BY TARGET THEN         
			INSERT(IDEmpleado,IDPeriodo,IDConcepto,CantidadMonto,CantidadDias,CantidadVeces,CantidadOtro1,CantidadOtro2,IDReferencia)        
			VALUES(SOURCE.IDEmpleado,SOURCE.IDPeriodo,SOURCE.IDConcepto        
			,CASE WHEN (ISNULL(SOURCE.CantidadMonto,0)>0)THEN SOURCE.CantidadMonto ELSE CASE WHEN (ISNULL(SOURCE.CantidadMonto,0) = -1) THEN -1 ELSE 0 END END        
			,CASE WHEN (ISNULL(SOURCE.CantidadDias,0)>0)THEN SOURCE.CantidadDias ELSE   CASE WHEN (ISNULL(SOURCE.CantidadDias,0) = -1) THEN -1 ELSE 0 END END        
			,CASE WHEN (ISNULL(SOURCE.CantidadVeces,0)>0)THEN SOURCE.CantidadVeces ELSE CASE WHEN (ISNULL(SOURCE.CantidadVeces,0) = -1) THEN -1 ELSE 0 END END        
			,CASE WHEN (ISNULL(SOURCE.CantidadOtro1,0)>0)THEN SOURCE.CantidadOtro1 ELSE CASE WHEN (ISNULL(SOURCE.CantidadOtro1,0) = -1) THEN -1 ELSE 0 END END        
			,CASE WHEN (ISNULL(SOURCE.CantidadOtro2,0)>0)THEN SOURCE.CantidadOtro2 ELSE CASE WHEN (ISNULL(SOURCE.CantidadOtro2,0) = -1) THEN -1 ELSE 0 END END        
			,CASE WHEN SOURCE.IDReferencia = 0 THEN null ELSE SOURCE.IDReferencia END  
			);      
        
        
END
GO
