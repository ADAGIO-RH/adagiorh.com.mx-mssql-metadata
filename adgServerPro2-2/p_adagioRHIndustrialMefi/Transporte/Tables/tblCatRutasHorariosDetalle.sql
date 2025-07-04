USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Transporte].[tblCatRutasHorariosDetalle](
	[IDRutaHorarioDetalle] [int] IDENTITY(1,1) NOT NULL,
	[IDRutaHorario] [int] NULL,
	[IDHorario] [int] NULL,
 CONSTRAINT [PK_tblCatRutasHorariosDetalle_IDRutaHorarioDetalle] PRIMARY KEY CLUSTERED 
(
	[IDRutaHorarioDetalle] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Transporte].[tblCatRutasHorariosDetalle]  WITH CHECK ADD  CONSTRAINT [FK_TransportetblCatRutasHorarios_TransportetblCatRutasHorariosDetalle_IDRutaHorario] FOREIGN KEY([IDRutaHorario])
REFERENCES [Transporte].[tblCatRutasHorarios] ([IDRutaHorario])
GO
ALTER TABLE [Transporte].[tblCatRutasHorariosDetalle] CHECK CONSTRAINT [FK_TransportetblCatRutasHorarios_TransportetblCatRutasHorariosDetalle_IDRutaHorario]
GO
