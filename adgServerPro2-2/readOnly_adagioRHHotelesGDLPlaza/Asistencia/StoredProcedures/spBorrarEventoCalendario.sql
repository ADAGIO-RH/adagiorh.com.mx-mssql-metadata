USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Descripción  : Eliminar eventos del calendario  
** Autor   : Aneudy Abreu  
** Email   : aneudy.abreu@adagio.com.mx  
** FechaCreacion : 2018-05-22  
** Paremetros  :   @TipoEvento int  
        ,@ID int  
        ,@FechaIni date  
        ,@FechaFin date  
        ,@IDUsuario int  
        ,@ConfirmadoEliminar bit = 0  
              
** Notas: Temp table #tempResponse - TipoRespuesta  
  -1 - Sin respuesta  
   0 - Eliminado  
   1 - EsperaDeConfirmación  
     
      
    TipoEvento  
    1 - Incidencias  
    2 - Ausentismos  
    3 - Horarios  
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
0000-00-00  NombreCompleto  ¿Qué cambió?  
***************************************************************************************************/  
CREATE proc [Asistencia].[spBorrarEventoCalendario](  
    @TipoEvento int  
    ,@ID int  
    ,@FechaIni date  
    ,@FechaFin date  
    ,@IDUsuario int  
    ,@ConfirmadoEliminar bit = 0  
) as  
    declare @IDEmpleado int ;  
  
   DECLARE @OldJSON Varchar(Max),
			@NewJSON Varchar(Max);


    if object_id('tempdb..#tempResponse') is not null drop table #tempResponse;  
  
    create table #tempResponse(  
		ID int  
		,TipoEvento int  
		,Mensaje Nvarchar(max)  
		,TipoRespuesta int  
		--,ConfirmarEliminar bit default 0  
    );  
  
    if ((@TipoEvento = 1) or (@TipoEvento = 2))  
    begin  
		select @IDEmpleado = IDEmpleado   
		from [Asistencia].[tblIncidenciaEmpleado]  
		where IDIncidenciaEmpleado = @ID  
        
		insert into #tempResponse(ID,Mensaje,TipoRespuesta)  
		exec [Asistencia].[spBorrarIncidenciasAusentismos]   
			 @IDIncidenciaEmpleado = @ID  
			,@IDEmpleado = @IDEmpleado  
			,@IDUsuario = @IDUsuario  
			,@ConfirmadoEliminar = @ConfirmadoEliminar  
    end;  
  
    if (@TipoEvento = 3)  
    BEGIN  
		select @IDEmpleado = IDEmpleado   
		from [Asistencia].tblHorariosEmpleados  
		where IDHorarioEmpleado = @ID  
  
		insert into #tempResponse(ID,Mensaje,TipoRespuesta)  
		exec [Asistencia].[spBorrarHorarioEmpleado]  
			 @IDEmpleado = @IDEmpleado   
			,@FechaIni = @FechaIni  
			,@FechaFin = @FechaFin  
			,@IDUsuario = @IDUsuario   
    END; 
	
	if(@TipoEvento = 4)
	BEGIN
		select @IDEmpleado = IDEmpleado
		from [Asistencia].[tblChecadas]
		where IDChecada = @ID

		insert into #tempResponse(ID, Mensaje, TipoRespuesta)
		exec [Asistencia].[spBorrarChecada]
			@IDChecada = @ID
			,@IDEmpleado = @IDEmpleado
			,@IDUsuario = @IDUsuario

	END

	if(@TipoEvento = 5)
	BEGIN

		select @OldJSON = a.JSON from [Asistencia].[tblPapeletas] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDPapeleta = @ID

		
		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblPapeletas]','[Asistencia].[spBorrarEventoCalendario]','DELETE','',@OldJSON
		

		delete from Asistencia.tblPapeletas where IDPapeleta = @ID

		insert into #tempResponse(ID, Mensaje, TipoRespuesta)
		select @ID,'Papeleta eliminada correctamente',0 

	END
  
    update #tempResponse  
    set TipoEvento = @TipoEvento  
  
    select * from #tempResponse  
  
    return;
GO
