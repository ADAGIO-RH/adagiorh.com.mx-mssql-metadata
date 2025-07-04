USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Transporte].[tblRutasPersonal](
	[IDRutaPersonal] [int] IDENTITY(1,1) NOT NULL,
	[IDRuta1] [int] NULL,
	[IDRuta2] [int] NULL,
	[IDEmpleado] [int] NULL,
	[Nombres] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Apellidos] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaInicio] [date] NULL,
	[FechaFin] [date] NULL,
	[IDRutaHorario1] [int] NULL,
	[IDRutaHorario2] [int] NULL,
 CONSTRAINT [PK_tblCatRutasPersonal_IDRutaPersonal] PRIMARY KEY CLUSTERED 
(
	[IDRutaPersonal] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Transporte].[tblRutasPersonal] ADD  DEFAULT ((0)) FOR [IDRutaHorario1]
GO
ALTER TABLE [Transporte].[tblRutasPersonal] ADD  DEFAULT ((0)) FOR [IDRutaHorario2]
GO
ALTER TABLE [Transporte].[tblRutasPersonal]  WITH CHECK ADD  CONSTRAINT [FK_TransportetblCatRutas_TransportetblRutasPersonal_IDRuta1] FOREIGN KEY([IDRuta1])
REFERENCES [Transporte].[tblCatRutas] ([IDRuta])
GO
ALTER TABLE [Transporte].[tblRutasPersonal] CHECK CONSTRAINT [FK_TransportetblCatRutas_TransportetblRutasPersonal_IDRuta1]
GO
ALTER TABLE [Transporte].[tblRutasPersonal]  WITH CHECK ADD  CONSTRAINT [FK_TransportetblCatRutas_TransportetblRutasPersonal_IDRuta2] FOREIGN KEY([IDRuta2])
REFERENCES [Transporte].[tblCatRutas] ([IDRuta])
GO
ALTER TABLE [Transporte].[tblRutasPersonal] CHECK CONSTRAINT [FK_TransportetblCatRutas_TransportetblRutasPersonal_IDRuta2]
GO
