USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Guarda y actualiza incidencias al catálogo
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-01-01
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
2019-11-29			Aneudy Abreu		Se agregó el campo [GenerarIncidencias]
***************************************************************************************************/
CREATE proc [Asistencia].[spIUIncidencia](  
    @IDIncidencia varchar(10)  
    ,@Descripcion varchar(255)  
    ,@EsAusentismo bit  
    ,@GoceSueldo bit  
    ,@PermiteChecar bit  
    ,@AfectaSUA bit  
    ,@Autorizar bit  
    ,@TiempoIncidencia bit  
    ,@Color varchar(20) 
	,@GenerarIncidencias bit 
	,@Intranet bit 
    ,@IDUsuario int  
	,@AdministrarSaldos bit
	,@Traduccion varchar(max)
	,@ReportePapeleta varchar(max)
	,@NombreProcedure varchar(max)
) as  
BEGIN  

	DECLARE 
		@OldJSON Varchar(Max),
		@NewJSON Varchar(Max)
	;
	
	select @IDIncidencia = UPPER(@IDIncidencia)   
		  ,@Descripcion = UPPER(@Descripcion)   

	select @Traduccion=App.UpperJSONKeys(@Traduccion, 'Descripcion')

    if exists(select top 1 1 from [Asistencia].[tblCatIncidencias] with (nolock) where IDIncidencia = @IDIncidencia)  
    begin  
		select @OldJSON =  (SELECT IDIncidencia
                                ,EsAusentismo
                                ,GoceSueldo
                                ,PermiteChecar
                                ,AfectaSUA
                                ,TiempoIncidencia
                                ,Autorizar
                             ,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) as Descripcion
                            FROM  [Asistencia].[tblCatIncidencias]
                            WHERE IDIncidencia = @IDIncidencia FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) 

		update [Asistencia].[tblCatIncidencias]  
			set Descripcion		= @Descripcion   
				,EsAusentismo	= @EsAusentismo   
				,GoceSueldo     = @GoceSueldo   
				,PermiteChecar  = @PermiteChecar  
				,AfectaSUA		= @AfectaSUA  
				,Autorizar		= @Autorizar  
				,TiempoIncidencia	= @TiempoIncidencia  
				,Color				= @Color  
				,GenerarIncidencias = case when isnull(@EsAusentismo,0) = 0 then @GenerarIncidencias else 0 end
				,Intranet			= @Intranet
				,AdministrarSaldos	= @AdministrarSaldos
				,Traduccion			= case when ISJSON(@Traduccion) > 0 then @Traduccion else null end
				,ReportePapeleta	= case when ISJSON(@ReportePapeleta) > 0 then @ReportePapeleta else null end
				,NombreProcedure	= @NombreProcedure
		where IDIncidencia = @IDIncidencia  
		
		select @NewJSON =  (SELECT IDIncidencia
                                ,EsAusentismo
                                ,GoceSueldo
                                ,PermiteChecar
                                ,AfectaSUA
                                ,TiempoIncidencia
                                ,Autorizar
                             ,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) as Descripcion
                            FROM  [Asistencia].[tblCatIncidencias]
                            WHERE IDIncidencia = @IDIncidencia FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

  
		 
		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblCatIncidencias]','[Asistencia].[spIUIncidencia]','UPDATE',@NewJSON,@OldJSON
    end else  
    begin  
		insert into [Asistencia].[tblCatIncidencias](
			IDIncidencia
			,Descripcion
			,EsAusentismo
			,GoceSueldo
			,PermiteChecar
			,AfectaSUA
			,Autorizar
			,TiempoIncidencia
			,Color
			,GenerarIncidencias
			,Intranet
			,AdministrarSaldos
			,Traduccion
			,ReportePapeleta
			,NombreProcedure)  
		select 
			@IDIncidencia
			,@Descripcion
			,@EsAusentismo
			,@GoceSueldo
			,@PermiteChecar
			,@AfectaSUA
			,@Autorizar
			,@TiempoIncidencia
			,@Color
			,case when isnull(@EsAusentismo,0) = 0 then @GenerarIncidencias else 0 end
			, @Intranet
			, @AdministrarSaldos
			, case when ISJSON(@Traduccion) > 0 then @Traduccion else null end
			, case when ISJSON(@ReportePapeleta) > 0 then @ReportePapeleta else null end
			,@NombreProcedure

		select @NewJSON =  (SELECT IDIncidencia
                                ,EsAusentismo
                                ,GoceSueldo
                                ,PermiteChecar
                                ,AfectaSUA
                                ,TiempoIncidencia
                                ,Autorizar
                             ,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) as Descripcion
                            FROM  [Asistencia].[tblCatIncidencias]
                            WHERE IDIncidencia = @IDIncidencia FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

  
		 
		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblCatIncidencias]','[Asistencia].[spIUIncidencia]','INSERT',@NewJSON,''

    end;  
  
    exec [Asistencia].[spBuscarCatIncidencias] @IDIncidencia=@IDIncidencia,@IDUsuario=@IDUsuario  
END;
GO
