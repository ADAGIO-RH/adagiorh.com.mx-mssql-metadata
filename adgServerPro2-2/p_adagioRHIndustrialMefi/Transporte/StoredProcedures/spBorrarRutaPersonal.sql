USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Autor   : Jose Vargas
** Email   : jvargas@adagio.com.mx  
** FechaCreacion : 2022-03-07
** Paremetros  :                
  
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
***************************************************************************************************/  
CREATE PROCEDURE [Transporte].[spBorrarRutaPersonal]
(
	@IDRutaPersonal int,
	@IDUsuario int
)
AS
BEGIN

    DECLARE @OldJSON Varchar(Max),
    @NewJSON Varchar(Max),
    @MsjError varchar(max),
    @IDRutaPersonalMayor int,
    @IDRutaPersonalMenor int,
    @FechaFin date,
    @FechaInicio date,
    @IDEmpleado int 

    
    if exists(select top 1 s.IDRutaPersonal from Transporte.tblRutasProgramadasPersonal s where s.IDRutaPersonal=@IDRutaPersonal)
    begin             
        raiserror('Esta asignación de ruta no puede ser eliminada, por que se encuentra en uso.',16,1);
        return;
    end 
    /*select @OldJSON = a.JSON from [Transporte].[tblCatRutas] b
    Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
    WHERE b.IDRuta = @IDRuta*/        
    BEGIN TRY                  
        select @IDEmpleado=IDEmpleado, @FechaFin=FechaFin,@FechaInicio=FechaInicio from Transporte.tblRutasPersonal P where p.IDRutaPersonal=@IDRutaPersonal                                
        if @IDEmpleado <> 0 
        begin 
            SELECT top 1  @IDRutaPersonalMayor=IDRutaPersonal  FROM Transporte.tblRutasPersonal  p
            where p.FechaInicio>@FechaInicio and  p.IDRutaPersonal<>@IDRutaPersonal and p.IDEmpleado=@IDEmpleado
            ORDER BY FechaInicio

            SELECT top 1 @IDRutaPersonalMenor=IDRutaPersonal FROM Transporte.tblRutasPersonal  p
            where p.FechaInicio<@FechaInicio and (@IDRutaPersonal =0 or p.IDRutaPersonal<>@IDRutaPersonal  ) and p.IDEmpleado=@IDEmpleado
            ORDER BY FechaInicio desc

            IF(@IDRutaPersonalMayor IS  NULL )
                BEGIN
                    set @FechaFin='9999-12-31'
                END
            
            IF(@IDRutaPersonalMenor IS NOT NULL )
                BEGIN
                    UPDATE Transporte.tblRutasPersonal SET FechaFin=@FechaFin
                    WHERE IDRutaPersonal=@IDRutaPersonalMenor
                END
        END                
        DELETE Transporte.tblRutasPersonal where IDRutaPersonal=@IDRutaPersonal
 	            
    END TRY  
    BEGIN CATCH  
	   EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
	   return 0;
    END CATCH ;

END
GO
