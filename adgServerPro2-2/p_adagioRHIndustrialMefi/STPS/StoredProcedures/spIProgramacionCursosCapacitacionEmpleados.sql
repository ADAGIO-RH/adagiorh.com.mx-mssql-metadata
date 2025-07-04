USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
CREATE PROCEDURE [STPS].[spIProgramacionCursosCapacitacionEmpleados]  
(    
 @IDEmpleado int,    
 @IDProgramacionCursoCapacitacion int,    
 @IDUsuario int    
)    
AS    
BEGIN    
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[STPS].[spIProgramacionCursosCapacitacionEmpleados]',
		@Tabla		varchar(max) = '[STPS].[tblProgramacionCursosCapacitacionEmpleados]',
		@Accion		varchar(20)	= 'INSERT',
		@Mensaje	varchar(max),
		@InformacionExtra	varchar(max)
	;

	IF NOT EXISTS(Select top 1 1 
				from STPS.tblProgramacionCursosCapacitacionEmpleados with (nolock)
				where IDProgramacionCursoCapacitacion = @IDProgramacionCursoCapacitacion  
		and IDEmpleado = @IDEmpleado)    
	BEGIN  
		INSERT INTO STPS.tblProgramacionCursosCapacitacionEmpleados(IDProgramacionCursoCapacitacion,IDEmpleado, Fecha, IDEstatusCursoEmpleados)   
		VALUES(@IDProgramacionCursoCapacitacion, @IDEmpleado, GETDATE(),(select top 1 IDEstatusCursoEmpleados from STPS.tblEstatusCursosEmpleados where Descripcion = 'NO EVALUADO'))    

		select @OldJSON = a.JSON 
			from (
				select 
					pcce.IDProgramacionCursosCapacitacionEmpleados
					,pcce.IDProgramacionCursoCapacitacion
					,pcce.IDEmpleado
					,pcce.Fecha
					,isnull(pcce.IDEstatusCursoEmpleados,0) as IDEstatusCursoEmpleados
					,pcce.Calificacion
				from STPS.tblProgramacionCursosCapacitacionEmpleados pcce with (nolock)
					join STPS.tblProgramacionCursosCapacitacion pcc with (nolock) on pcc.IDProgramacionCursoCapacitacion = pcce.IDProgramacionCursoCapacitacion
					join STPS.tblCursosCapacitacion cc with (nolock) on cc.IDCursoCapacitacion = pcc.IDCursoCapacitacion
					join RH.tblEmpleadosMaster e with (nolock) on e.IDEmpleado = pcce.IDEmpleado
					left join STPS.tblEstatusCursosEmpleados ece with (nolock) on ece.IDEstatusCursoEmpleados = pcce.IDEstatusCursoEmpleados
				where pcce.IDProgramacionCursoCapacitacion = @IDProgramacionCursoCapacitacion and pcce.IDEmpleado = @IDEmpleado
			) b
				Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a

		EXEC [Auditoria].[spIAuditoria]
			@IDUsuario		= @IDUsuario
			,@Tabla			= @Tabla
			,@Procedimiento	= @NombreSP
			,@Accion		= @Accion
			,@NewData		= @NewJSON
			,@OldData		= @OldJSON
			,@Mensaje		= @Mensaje
			,@InformacionExtra		= @InformacionExtra
	END    
    
END;
GO
