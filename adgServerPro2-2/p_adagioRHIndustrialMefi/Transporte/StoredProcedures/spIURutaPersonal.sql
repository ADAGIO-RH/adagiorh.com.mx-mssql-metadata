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
CREATE proc [Transporte].[spIURutaPersonal](
        
        @IDRutaPersonal int null 
        ,@IDEmpleado int null	 		
        ,@Nombres VARCHAR (100)
        ,@Apellidos VARCHAR (100)
        ,@FechaInicio DATE        
        ,@FechaFin DATE =null       
        ,@IDRuta1 int null	 		
        ,@IDRuta2 int null	 		
        ,@IDRutaHorario1 int null	 		
        ,@IDRutaHorario2 int null	 		
        ,@IDUsuario int null	 		
	)
AS  
BEGIN  

    select
		@Nombres = UPPER(@Nombres),
		@Apellidos   = UPPER(@Apellidos)
		


    DECLARE @OldJSON Varchar(Max),
	    @NewJSON Varchar(Max),
        @IDRutaPersonalMayor int,
        @IDRutaPersonalMenor int,
        @MsjError varchar(max)
    
    if @FechaFin ='1753-01-01'
    begin 
        set @FechaFin=null
    end 

    if @IDEmpleado <> 0 
    begin 



        if exists(select top 1 s.IDRutaPersonal from Transporte.tblRutasPersonal s where s.IDEmpleado=@IDEmpleado and (s.FechaFin = @FechaInicio or s.FechaInicio=@FechaInicio))
        begin 
            select @MsjError=concat('El empleado ya tiene configurada una ruta para la fecha <b>',@FechaInicio,'</b>')
            raiserror(@MsjError,16,1);
		    return;
        end 

        SELECT top 1  @IDRutaPersonalMayor=IDRutaPersonal,@FechaFin=DATEADD(day, -1,FechaInicio)  FROM Transporte.tblRutasPersonal  p
        where p.FechaInicio>@FechaInicio and (@IDRutaPersonal =0 or p.IDRutaPersonal<>@IDRutaPersonal  ) and p.IDEmpleado=@IDEmpleado
        ORDER BY FechaInicio

        
        SELECT top 1 @IDRutaPersonalMenor=IDRutaPersonal FROM Transporte.tblRutasPersonal  p
        where p.FechaInicio<@FechaInicio and (@IDRutaPersonal =0 or p.IDRutaPersonal<>@IDRutaPersonal  ) and p.IDEmpleado=@IDEmpleado
        ORDER BY FechaInicio desc
        

        IF(@IDRutaPersonalMenor IS NOT NULL )
            BEGIN
                
                UPDATE Transporte.tblRutasPersonal SET FechaFin=DATEADD(day, -1,  @FechaInicio) 
                WHERE IDRutaPersonal=@IDRutaPersonalMenor
            END
        
        set @FechaFin= isnull(@FechaFin,'9999-12-31')
        set @IDRutaHorario1=null;
        set @IDRutaHorario2=null;
    end 
    

    IF(@IDRutaPersonal = 0)  
        BEGIN  	                                                
            insert into   [Transporte].[tblRutasPersonal] (IDEmpleado,Nombres,Apellidos,FechaInicio,FechaFin,IDRuta1,IDRuta2,IDRutaHorario1,IDRutaHorario2) 
            VALUES (@IDEmpleado,@Nombres,@Apellidos,@FechaInicio,@FechaFin,@IDRuta1,@IDRuta2,@IDRutaHorario1,@IDRutaHorario2)        
            set @IDRutaPersonal = @@IDENTITY           
         END  
    ELSE  
        BEGIN  	
            update [Transporte].[tblRutasPersonal] 
            set 
            FechaInicio=@FechaInicio,
            FechaFin=@FechaFin,
            IDRuta1=@IDRuta1,
            IDRuta2=@IDRuta2,
            Nombres=@Nombres,
            Apellidos=@Apellidos,
            IDRutaHorario1=@IDRutaHorario1,
            IDRutaHorario2=@IDRutaHorario2
            where IDRutaPersonal=@IDRutaPersonal
        end
                                                                                                                                               
	    /* 
	  	select @NewJSON = a.JSON from [Transporte].[tblCatRutas] b                                                                          
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDRuta = @IDRuta                                                                                                          

        set @IDRuta=@@IDENTITY;
		--EXEC [Auditoria].[spIAuditoria] @IDVehiculo,'[Transporte].[tblCatRutas]','[Transporte].[spIURuta]','INSERT',@NewJSON,''*/                                        
          
	                                                                                                                                                                                
      
END
GO
